-- ═══════════════════════════════════════════════════════════════════
-- Paigham — ALL database fixes in ONE file. Run this once in the
-- Supabase SQL Editor; it replaces fast_sending.sql,
-- reliability_checks.sql, gateway_owner.sql and add_sim_slot.sql.
--
-- SAFE TO RE-RUN: every statement is idempotent — columns and
-- constraints that already exist are skipped or replaced, never an
-- "already exists" error. Anything missed earlier gets applied;
-- anything already applied is left untouched.
-- ═══════════════════════════════════════════════════════════════════

-- 1) Sending SIM choice (app_settings.sim_slot) ─────────────────────
alter table public.app_settings
  add column if not exists sim_slot int not null default -1;

-- 2) Fast sending: delay range 0–5s (0 = next SMS starts immediately,
--    like the phone's own Messages app), default 2s ────────────────
alter table public.app_settings
  drop constraint if exists app_settings_delay_seconds_check;

alter table public.app_settings
  add constraint app_settings_delay_seconds_check
  check (delay_seconds between 0 and 5);

alter table public.app_settings
  alter column delay_seconds set default 2;

update public.app_settings
  set delay_seconds = 2
  where delay_seconds > 5;

-- 3) Single active gateway: ownership token on the gateway row ─────
alter table public.gateway
  add column if not exists owner_id text;

-- 4) Reliability checks: allow the new failure reasons the gateway
--    writes back (noPermission / noSim / limitReached) ─────────────
alter table public.delivery_logs
  drop constraint if exists delivery_logs_reason_check;

alter table public.delivery_logs
  add constraint delivery_logs_reason_check
  check (reason in ('networkBusy', 'numberOff', 'timeout', 'lowBalance',
                    'notExist', 'stopped', 'noPermission', 'noSim',
                    'limitReached'));
