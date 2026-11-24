# send-sms function — setup

1. Install the Supabase CLI: https://supabase.com/docs/guides/cli
2. Login + link this project:
   - `supabase login`
   - `supabase link --project-ref hpyqehdxpspyvfwohflu`
3. Set the EasySendSMS key as a secret (get the key from your EasySendSMS dashboard → API settings):
   - `supabase secrets set EASYSENDSMS_API_KEY=YOUR_KEY_HERE`
4. Deploy:
   - `supabase functions deploy send-sms`

Notes:
- The key stays in Supabase secrets only — never put it in the app code.
- In the app, **Test Mode ON** = simulation (nothing is really sent). **Test Mode OFF** = real SMS go through this function.
