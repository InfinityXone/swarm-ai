create extension if not exists pgcrypto;
create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  status text check (status in ('queued','running','done','error')) default 'queued',
  action text not null,
  args jsonb not null,
  result jsonb
);
create index if not exists tasks_status_idx on tasks(status);
create table if not exists agents (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  repo text,
  endpoint text,
  created_at timestamptz default now()
);
create table if not exists events (
  id bigserial primary key,
  created_at timestamptz default now(),
  subject text,
  data jsonb
);
