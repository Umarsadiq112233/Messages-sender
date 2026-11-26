-- ════════════════════════════════════════════════════════════════════════
-- Paigham SMS Panel — Supabase schema
-- Run once: Supabase Dashboard → SQL Editor → New query → paste → Run.
-- Safe to re-run (everything is "if not exists" / "or replace").
--
-- Access model: one shared admin account (Supabase Auth, email+password).
-- Every table is protected by RLS: only signed-in users can read/write;
-- the public anon key alone can see nothing.
-- ════════════════════════════════════════════════════════════════════════

create extension if not exists pgcrypto;

-- ─────────────────────────── Groups ───────────────────────────
create table if not exists public.groups (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (length(trim(name)) > 0),
  color_index int  not null default 0,
  created_at  timestamptz not null default now()
);
create unique index if not exists groups_name_unique on public.groups (lower(name));

-- ─────────────────────────── Contacts (numbers) ───────────────────────────
create table if not exists public.contacts (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  phone      text not null check (phone ~ '^03[0-9]{9}$'),   -- 03XXXXXXXXX
  group_id   uuid references public.groups (id) on delete set null,
  note       text not null default '',
  created_at timestamptz not null default now()
);
create unique index if not exists contacts_phone_unique on public.contacts (phone);
create index if not exists contacts_group_idx on public.contacts (group_id);
create index if not exists contacts_created_idx on public.contacts (created_at desc);

-- ─────────────────────────── Campaigns ───────────────────────────
create table if not exists public.campaigns (
  id             uuid primary key default gen_random_uuid(),
  message        text not null,
  audience_kind  text not null default 'all'
                 check (audience_kind in ('all', 'group', 'selected', 'retry', 'test')),
  audience_name  text,
  audience_count int  not null default 0,
  segments       int  not null default 1 check (segments >= 1),
  state          text not null default 'running'
                 check (state in ('running', 'paused', 'stopped', 'completed')),
  pause_reason   text check (pause_reason in ('user', 'gateway')),
  created_at     timestamptz not null default now(),
  finished_at    timestamptz
);
create index if not exists campaigns_created_idx on public.campaigns (created_at desc);

-- ─────────────────────────── Delivery logs (one row per SMS) ───────────────────────────
create table if not exists public.delivery_logs (
  id          uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns (id) on delete cascade,
  contact_id  uuid references public.contacts (id) on delete set null,
  name        text not null,
  phone       text not null,
  status      text not null default 'pending'
              check (status in ('pending', 'sending', 'sent', 'failed')),
  reason      text check (reason in ('networkBusy', 'numberOff', 'timeout', 'lowBalance', 'notExist', 'stopped', 'noPermission', 'noSim', 'limitReached')),
  sent_at     timestamptz,
  position    int not null default 0
);
create index if not exists delivery_logs_campaign_idx on public.delivery_logs (campaign_id, position);
create index if not exists delivery_logs_contact_idx on public.delivery_logs (contact_id);
create index if not exists delivery_logs_sent_idx on public.delivery_logs (sent_at desc);

-- ─────────────────────────── Activity log ───────────────────────────
create table if not exists public.activities (
  id         uuid primary key default gen_random_uuid(),
  event      text not null,
  args       text[] not null default '{}',
  created_at timestamptz not null default now()
);
create index if not exists activities_created_idx on public.activities (created_at desc);

-- ─────────────────────────── Settings (single row, id = 1) ───────────────────────────
create table if not exists public.app_settings (
  id                int primary key default 1 check (id = 1),
  daily_limit       int  not null default 100 check (daily_limit > 0),
  package_remaining int  not null default 0 check (package_remaining >= 0),
  delay_seconds     int  not null default 2 check (delay_seconds between 0 and 5),
  test_mode         boolean not null default true,
  sim_slot          int  not null default -1,
  updated_at        timestamptz not null default now()
);
insert into public.app_settings (id) values (1) on conflict (id) do nothing;

-- Migration for existing databases (safe to re-run): the gateway phone's
-- chosen sending SIM slot (0 = SIM 1, 1 = SIM 2, -1 = phone default).
alter table public.app_settings add column if not exists sim_slot int not null default -1;

-- ─────────────────────────── Gateway device (single row, id = 1) ───────────────────────────
-- The Android gateway app (Phase 3) will update this row; the panel shows it.
create table if not exists public.gateway (
  id                int primary key default 1 check (id = 1),
  connected         boolean not null default false,
  device_name       text not null default 'Android phone',
  model             text not null default '',
  sim_number        text not null default '',
  operator          text not null default '',
  signal            int  not null default 0 check (signal between 0 and 4),
  battery           int  not null default 0 check (battery between 0 and 100),
  charging          boolean not null default false,
  last_seen         timestamptz not null default now(),
  pair_code         text not null default lpad((floor(random() * 1000))::text, 3, '0') || '-' || lpad((floor(random() * 1000))::text, 3, '0'),
  disconnect_reason text check (disconnect_reason in ('lostConnection', 'byUser')),
  owner_id          text
);
insert into public.gateway (id) values (1) on conflict (id) do nothing;

-- Migration for existing databases (safe to re-run): the ownership
-- token of the one active gateway run (single gateway; the newest
-- connect wins and the previous gateway stops itself).
alter table public.gateway add column if not exists owner_id text;

-- ─────────────────────────── Row Level Security ───────────────────────────
-- Shared admin account: any signed-in user has full access; anonymous has none.
do $$
declare t text;
begin
  foreach t in array array['groups', 'contacts', 'campaigns', 'delivery_logs', 'activities', 'app_settings', 'gateway']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "signed-in full access" on public.%I', t);
    execute format(
      'create policy "signed-in full access" on public.%I for all to authenticated using (true) with check (true)', t);
    execute format('revoke all on public.%I from anon', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;
end $$;

-- ─────────────────────────── Realtime (live queue / multi-device) ───────────────────────────
do $$
declare t text;
begin
  foreach t in array array['delivery_logs', 'campaigns', 'gateway']
  loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;
