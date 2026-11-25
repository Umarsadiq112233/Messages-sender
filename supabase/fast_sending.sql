-- Fast sending: the per-message delay used to default to 20s
-- (allowed 5-120s), which made campaigns feel very slow.
-- New range is 1-5s with a default of 2s, and any saved slow
-- value is brought down to 2s. Run once in the SQL editor.

alter table public.app_settings
  drop constraint if exists app_settings_delay_seconds_check;

alter table public.app_settings
  add constraint app_settings_delay_seconds_check
  check (delay_seconds between 1 and 5);

alter table public.app_settings
  alter column delay_seconds set default 2;

update public.app_settings
  set delay_seconds = 2
  where delay_seconds > 5;
