-- Single active gateway: an ownership token on the gateway row.
-- Every gateway run stamps its own token with its heartbeat. A run
-- that finds a DIFFERENT token on the row knows another phone has
-- connected since (newest connect wins) and stops itself — so two
-- phones signed into the same account can never both act as the
-- gateway and send at once. Run once in the SQL editor. Safe to re-run.

alter table public.gateway add column if not exists owner_id text;
