package com.example.messege_sender

import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.SmsManager
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// Hosts the `paigham/sms` channel: everything the gateway needs from the
/// phone itself — the SEND_SMS permission, sending through the SIM, and
/// device identity for the gateway heartbeat.
class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "paigham/sms"
        const val SMS_PERMISSION_REQUEST = 4101
        const val PHONE_STATE_PERMISSION_REQUEST = 4102
        const val SEND_TIMEOUT_MS = 20_000L
    }

    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingPhoneStateResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestSmsPermission" -> requestSmsPermission(result)
                    "hasSmsPermission" -> result.success(hasSmsPermission())
                    "requestPhoneStatePermission" -> requestPhoneStatePermission(result)
                    "listSims" -> result.success(listSims())
                    "sendSms" -> sendSms(
                        call.argument<String>("to"),
                        call.argument<String>("message"),
                        call.argument<Int>("simSlot"),
                        result,
                    )
                    "deviceInfo" -> result.success(deviceInfo())
                    "batteryInfo" -> result.success(batteryInfo())
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasSmsPermission(): Boolean =
        ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) ==
            PackageManager.PERMISSION_GRANTED

    private fun requestSmsPermission(result: MethodChannel.Result) {
        if (hasSmsPermission()) {
            result.success(true)
            return
        }
        if (pendingPermissionResult != null) {
            // The system permission dialog is already showing.
            result.success(false)
            return
        }
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.SEND_SMS),
            SMS_PERMISSION_REQUEST,
        )
    }

    private fun hasPhoneStatePermission(): Boolean =
        ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) ==
            PackageManager.PERMISSION_GRANTED

    private fun requestPhoneStatePermission(result: MethodChannel.Result) {
        if (hasPhoneStatePermission()) {
            result.success(true)
            return
        }
        if (pendingPhoneStateResult != null) {
            // The system permission dialog is already showing.
            result.success(false)
            return
        }
        pendingPhoneStateResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.READ_PHONE_STATE),
            PHONE_STATE_PERMISSION_REQUEST,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        when (requestCode) {
            SMS_PERMISSION_REQUEST -> {
                pendingPermissionResult?.success(granted)
                pendingPermissionResult = null
            }
            PHONE_STATE_PERMISSION_REQUEST -> {
                pendingPhoneStateResult?.success(granted)
                pendingPhoneStateResult = null
            }
        }
    }

    private fun subscriptionManager(): SubscriptionManager? = try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            getSystemService(SubscriptionManager::class.java)
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
        }
    } catch (e: Exception) {
        null
    }

    /// The phone's active SIMs, one map per subscription, sorted by
    /// physical slot. Listing them needs READ_PHONE_STATE; without it
    /// (or on any error) this returns an empty list — never crashes.
    private fun listSims(): List<Map<String, Any>> {
        if (!hasPhoneStatePermission()) return emptyList()
        return try {
            val subs = subscriptionManager()?.activeSubscriptionInfoList ?: return emptyList()
            subs.sortedBy { it.simSlotIndex }.map { info ->
                val carrier = info.carrierName?.toString()?.takeIf { it.isNotEmpty() }
                    ?: info.displayName?.toString()?.takeIf { it.isNotEmpty() }
                    ?: ""
                // The number is permission-gated and often empty on
                // modern Android — best-effort only.
                val number = try {
                    @Suppress("DEPRECATION")
                    info.number ?: ""
                } catch (e: Exception) {
                    ""
                }
                mapOf<String, Any>(
                    "slot" to info.simSlotIndex,
                    "subscriptionId" to info.subscriptionId,
                    "carrier" to carrier,
                    "number" to number,
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /// Resolves the subscription id for a physical SIM [slot], or null
    /// when that slot has no active subscription (or SIM info can't be
    /// read). A chosen SIM that can't be resolved must fail the send —
    /// never fall back to a different SIM.
    private fun subscriptionIdForSlot(slot: Int): Int? {
        if (!hasPhoneStatePermission()) return null
        return try {
            subscriptionManager()?.activeSubscriptionInfoList
                ?.firstOrNull { it.simSlotIndex == slot }
                ?.subscriptionId
        } catch (e: Exception) {
            null
        }
    }

    private fun sendSms(to: String?, message: String?, simSlot: Int?, result: MethodChannel.Result) {
        if (to.isNullOrBlank() || message.isNullOrBlank()) {
            result.error("bad_args", "Missing recipient or message", null)
            return
        }
        if (!hasSmsPermission()) {
            result.error("no_permission", "SEND_SMS permission not granted", null)
            return
        }

        // Resolve the chosen SIM up front: if a slot was chosen but has
        // no active subscription, fail with "noSim" — never silently
        // send from a different SIM than the one the user selected.
        var subscriptionId: Int? = null
        if (simSlot != null && simSlot >= 0) {
            subscriptionId = subscriptionIdForSlot(simSlot)
            if (subscriptionId == null) {
                result.success(mapOf("ok" to false, "code" to "noSim"))
                return
            }
        }

        // A unique action per send, so this send's result broadcast can
        // never be confused with another send's.
        val action = "com.example.messege_sender.SMS_SENT.${System.nanoTime()}"
        val handler = Handler(Looper.getMainLooper())
        var receiver: BroadcastReceiver? = null
        var completed = false

        // Completes the channel result exactly once, with the radio's
        // real outcome: {ok, code}. Unregisters the receiver and cancels
        // the safety timeout.
        fun finish(ok: Boolean, code: String) {
            if (completed) return
            completed = true
            handler.removeCallbacksAndMessages(null)
            receiver?.let {
                try {
                    unregisterReceiver(it)
                } catch (e: Exception) {
                    // Already unregistered — nothing to clean up.
                }
            }
            receiver = null
            result.success(mapOf("ok" to ok, "code" to code))
        }

        try {
            val defaultManager: SmsManager =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    getSystemService(SmsManager::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    SmsManager.getDefault()
                }
            // A chosen SIM sends through its own subscription's manager;
            // no chosen SIM keeps the phone-default behavior exactly.
            val smsManager: SmsManager = if (subscriptionId != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    defaultManager.createForSubscriptionId(subscriptionId)
                } else {
                    @Suppress("DEPRECATION")
                    SmsManager.getSmsManagerForSubscriptionId(subscriptionId)
                }
            } else {
                defaultManager
            }
            val parts = smsManager.divideMessage(message)
            val partCount = if (parts.isEmpty()) 1 else parts.size
            var remaining = partCount

            val sentReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (resultCode == Activity.RESULT_OK) {
                        remaining -= 1
                        // Multipart: only done when EVERY part is accepted.
                        if (remaining <= 0) finish(true, "ok")
                    } else {
                        finish(false, codeForResult(resultCode))
                    }
                }
            }
            receiver = sentReceiver
            val filter = IntentFilter(action)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(sentReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(sentReceiver, filter)
            }
            // If the radio never reports back, fail as a timeout instead
            // of leaving the Dart side waiting forever.
            handler.postDelayed({ finish(false, "timeout") }, SEND_TIMEOUT_MS)

            val requestCode = (System.nanoTime() and 0x7fffffff).toInt()
            val sentIntent = PendingIntent.getBroadcast(
                this,
                requestCode,
                Intent(action),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            if (partCount <= 1) {
                smsManager.sendTextMessage(to, null, message, sentIntent, null)
            } else {
                val sentIntents = ArrayList<PendingIntent>()
                repeat(partCount) { sentIntents.add(sentIntent) }
                smsManager.sendMultipartTextMessage(to, null, parts, sentIntents, null)
            }
        } catch (e: Exception) {
            if (receiver != null) {
                finish(false, "sendFailed")
            } else {
                result.error("send_failed", e.message, null)
            }
        }
    }

    /// Maps an SmsManager sent-result code to the stable string codes the
    /// Dart side translates into user-facing failure reasons.
    private fun codeForResult(resultCode: Int): String = when (resultCode) {
        SmsManager.RESULT_ERROR_GENERIC_FAILURE -> "genericFailure"
        SmsManager.RESULT_ERROR_NO_SERVICE -> "noService"
        SmsManager.RESULT_ERROR_NULL_PDU -> "nullPdu"
        SmsManager.RESULT_ERROR_RADIO_OFF -> "radioOff"
        else -> {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R &&
                resultCode == SmsManager.RESULT_ERROR_LIMIT_EXCEEDED
            ) {
                "limitExceeded"
            } else {
                "sendFailed"
            }
        }
    }

    /// The phone's real battery right now: `battery` is the charge
    /// percentage (0–100, -1 when it can't be read) and `charging` is
    /// true while the phone is plugged in / full. Read fresh on every
    /// call so the gateway heartbeat always reports the live value.
    private fun batteryInfo(): Map<String, Any> {
        val level = try {
            val bm = getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
            bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) ?: -1
        } catch (e: Exception) {
            -1
        }
        val charging = try {
            // The sticky battery intent carries the current charge state.
            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
            status == BatteryManager.BATTERY_STATUS_CHARGING ||
                status == BatteryManager.BATTERY_STATUS_FULL
        } catch (e: Exception) {
            false
        }
        return mapOf("battery" to level, "charging" to charging)
    }

    private fun deviceInfo(): Map<String, String> {
        val manufacturer = Build.MANUFACTURER.replaceFirstChar { it.uppercase() }
        val operator = try {
            val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            tm.simOperatorName?.takeIf { it.isNotEmpty() } ?: tm.networkOperatorName ?: ""
        } catch (e: Exception) {
            ""
        }
        val battery = batteryInfo()
        return mapOf(
            "name" to "$manufacturer ${Build.MODEL}",
            "model" to "${Build.MODEL} · Android ${Build.VERSION.RELEASE}",
            "operator" to operator,
            "battery" to battery["battery"].toString(),
            "charging" to battery["charging"].toString(),
        )
    }
}
