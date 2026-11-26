-- Reliability checks: three new delivery failure reasons.
-- The gateway now writes back WHY a message was not sent in cases that
-- used to fail silently or with a misleading reason:
--   noPermission  — SEND_SMS permission revoked on the gateway phone
--   noSim         — the chosen SIM (or any SIM) is not in the gateway phone
--   limitReached  — the daily limit was already used up
-- The delivery_logs.reason CHECK constraint must allow the new values,
-- otherwise those write-backs are rejected and the logs stay pending.
-- Run once in the SQL editor. Safe to re-run.

alter table public.delivery_logs
  drop constraint if exists delivery_logs_reason_check;

alter table public.delivery_logs
  add constraint delivery_logs_reason_check
  check (reason in ('networkBusy', 'numberOff', 'timeout', 'lowBalance',
                    'notExist', 'stopped', 'noPermission', 'noSim',
                    'limitReached'));
