// Paigham — real SMS sending via EasySendSMS.
//
// The app calls this function (one recipient per call); the EasySendSMS API
// key lives only here, as the Supabase secret EASYSENDSMS_API_KEY, and is
// never shipped in the app.
//
// Request:  POST { "to": "+923001234567", "message": "Hello" }
// Response: { "ok": true }
//           { "ok": false, "error": "…" }  (with a matching HTTP status)
//
// EasySendSMS API verified against the official REST API v1 docs
// (github.com/EasySendSMS/REST-API-v1):
//   POST https://restapi.easysendsms.app/v1/rest/sms/send
//   Headers: apikey: <key>, Content-Type/Accept: application/json
//   Body:    { from, to, text, type } — `to` is digits only, country code
//            first, NO leading "+" or "00"; type "0" = plain, "1" = Unicode.
//   Success: HTTP 200, { status: "OK", messageIds: ["OK: <id>", …] }
//            (a recipient entry can instead be "ERR: <code>")
//   Error:   { error: <code>, description: "…" } with an HTTP status
//            (4012 invalid number → 400, 4015 no credits → 402, …)

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function json(body: Record<string, unknown>, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/** Calls EasySendSMS once. Returns an error message, or null on success. */
async function sendViaEasySendSms(
  apiKey: string,
  to: string,
  message: string,
): Promise<{ error: string; status: number } | null> {
  // Provider wants digits only: "+923001234567" → "923001234567".
  const digits = to.replace(/^\+/, "").replace(/^00/, "");
  // Urdu / any non-Latin text must go as Unicode (type "1").
  const type = /[^\x00-\x7F]/.test(message) ? "1" : "0";

  let res: Response;
  try {
    res = await fetch("https://restapi.easysendsms.app/v1/rest/sms/send", {
      method: "POST",
      headers: {
        "apikey": apiKey,
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: JSON.stringify({
        from: Deno.env.get("EASYSENDSMS_SENDER") ?? "Paigham",
        to: digits,
        text: message,
        type,
      }),
    });
  } catch (_) {
    return { error: "Could not reach the SMS provider.", status: 502 };
  }

  const data = await res.json().catch(() => null) as
    | { status?: string; messageIds?: string[]; description?: string }
    | null;

  if (!res.ok) {
    return {
      error: data?.description ?? `SMS provider error (HTTP ${res.status}).`,
      status: 502,
    };
  }
  // HTTP 200: the per-recipient entry decides ("OK: <id>" vs "ERR: <code>").
  const first = data?.messageIds?.[0] ?? "";
  if (data?.status === "OK" && first.startsWith("OK")) return null;
  if (first.startsWith("ERR")) {
    return { error: `SMS provider rejected the number (${first}).`, status: 400 };
  }
  return { error: "Unexpected response from the SMS provider.", status: 502 };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ ok: false, error: "Method not allowed." }, 405);
  }

  let to = "";
  let message = "";
  try {
    const body = await req.json() as { to?: unknown; message?: unknown };
    to = typeof body.to === "string" ? body.to.trim() : "";
    message = typeof body.message === "string" ? body.message : "";
  } catch (_) {
    return json({ ok: false, error: "Request body must be JSON." }, 400);
  }
  if (!to || !message.trim()) {
    return json({ ok: false, error: "Both 'to' and 'message' are required." }, 400);
  }

  const apiKey = Deno.env.get("EASYSENDSMS_API_KEY");
  if (!apiKey) {
    return json(
      { ok: false, error: "SMS provider is not configured (missing EASYSENDSMS_API_KEY)." },
      500,
    );
  }

  const failure = await sendViaEasySendSms(apiKey, to, message);
  if (failure) return json({ ok: false, error: failure.error }, failure.status);
  return json({ ok: true }, 200);
});
