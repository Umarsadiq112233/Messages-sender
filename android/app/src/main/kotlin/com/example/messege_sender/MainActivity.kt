package com.example.messege_sender

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SmsManager
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
    }

    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestSmsPermission" -> requestSmsPermission(result)
                    "sendSms" -> sendSms(
                        call.argument<String>("to"),
                        call.argument<String>("message"),
                        result,
                    )
                    "deviceInfo" -> result.success(deviceInfo())
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

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != SMS_PERMISSION_REQUEST) return
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingPermissionResult?.success(granted)
        pendingPermissionResult = null
    }

    private fun sendSms(to: String?, message: String?, result: MethodChannel.Result) {
        if (to.isNullOrBlank() || message.isNullOrBlank()) {
            result.error("bad_args", "Missing recipient or message", null)
            return
        }
        if (!hasSmsPermission()) {
            result.error("no_permission", "SEND_SMS permission not granted", null)
            return
        }
        try {
            val smsManager: SmsManager =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    getSystemService(SmsManager::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    SmsManager.getDefault()
                }
            val parts = smsManager.divideMessage(message)
            if (parts.size <= 1) {
                smsManager.sendTextMessage(to, null, message, null, null)
            } else {
                smsManager.sendMultipartTextMessage(to, null, parts, null, null)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("send_failed", e.message, null)
        }
    }

    private fun deviceInfo(): Map<String, String> {
        val manufacturer = Build.MANUFACTURER.replaceFirstChar { it.uppercase() }
        val operator = try {
            val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            tm.simOperatorName?.takeIf { it.isNotEmpty() } ?: tm.networkOperatorName ?: ""
        } catch (e: Exception) {
            ""
        }
        return mapOf(
            "name" to "$manufacturer ${Build.MODEL}",
            "model" to "${Build.MODEL} · Android ${Build.VERSION.RELEASE}",
            "operator" to operator,
        )
    }
}
