-- ════════════════════════════════════════════════════════════════════════
-- Paigham — create (or reset) the shared admin login.
--
-- 1. Change v_password below (min 8 characters). Keep this file's edited
--    copy private — don't commit the real password.
-- 2. Supabase Dashboard → SQL Editor → New query → paste → Run.
--
-- Safe to re-run: if the admin already exists, its password and name are
-- updated instead of creating a duplicate.
-- Login in the app: username "admin" + this password.
-- ════════════════════════════════════════════════════════════════════════

do $$
declare
  v_email    text := 'admin@nhf.com';           -- must match ADMIN_EMAIL in config/supabase.json
  v_password text := 'CHANGE_ME';              -- ← put the real password here
  v_name     text := 'Shakir';                 -- name shown in the panel
  v_id       uuid;
begin
  if v_password = 'CHANGE_ME' or length(v_password) < 4 then
    raise exception 'Pehle v_password mein asal password likhein.';
  end if;
  if length(v_password) < 8 then
    raise notice 'Tawajjo: password chhota hai — baad mein Settings se mazboot password rakh lein.';
  end if;

  select id into v_id from auth.users where email = v_email;

  if v_id is null then
    v_id := gen_random_uuid();

    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) values (
      '00000000-0000-0000-0000-000000000000', v_id, 'authenticated', 'authenticated',
      v_email, extensions.crypt(v_password, extensions.gen_salt('bf')), now(),
      '{"provider": "email", "providers": ["email"]}'::jsonb,
      jsonb_build_object('display_name', v_name),
      now(), now(), '', '', '', ''
    );

    insert into auth.identities (
      id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    ) values (
      gen_random_uuid(), v_id, v_id::text,
      jsonb_build_object('sub', v_id::text, 'email', v_email, 'email_verified', true),
      'email', now(), now(), now()
    );

    raise notice 'Admin account bana diya: %', v_email;
  else
    update auth.users
       set encrypted_password = extensions.crypt(v_password, extensions.gen_salt('bf')),
           email_confirmed_at = coalesce(email_confirmed_at, now()),
           raw_user_meta_data = coalesce(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('display_name', v_name),
           updated_at         = now()
     where id = v_id;

    raise notice 'Admin pehle se tha — password aur naam update kar diye: %', v_email;
  end if;
end $$;
