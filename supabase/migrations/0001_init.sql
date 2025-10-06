-- Supabase schema for Iniato
-- Enables required extensions
begin;

create extension if not exists "pgcrypto";

-- users table
create table if not exists public.users (
  id uuid primary key,
  name text,
  email text unique,
  role text check (role in ('passenger','driver')),
  vehicle_type text check (vehicle_type in ('ev','normal')),
  token_balance integer not null default 0,
  created_at timestamptz not null default now()
);

-- rides table
create table if not exists public.rides (
  id uuid primary key default gen_random_uuid(),
  passenger_id uuid not null references public.users(id) on delete cascade,
  driver_id uuid references public.users(id) on delete set null,
  distance_km double precision not null default 0,
  fare numeric(10,2) not null default 0,
  is_ev boolean not null default false,
  status text not null default 'requested' check (status in ('requested','accepted','completed')),
  created_at timestamptz not null default now()
);

create index if not exists rides_passenger_idx on public.rides(passenger_id);
create index if not exists rides_driver_idx on public.rides(driver_id);
create index if not exists rides_status_idx on public.rides(status);

-- transactions table
create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  ride_id uuid not null references public.rides(id) on delete cascade,
  tokens integer not null,
  reason text not null check (reason in ('EV Ride','EV Ride Completed')),
  created_at timestamptz not null default now()
);

create index if not exists transactions_user_idx on public.transactions(user_id);
create index if not exists transactions_ride_idx on public.transactions(ride_id);

-- RLS
alter table public.users enable row level security;
alter table public.rides enable row level security;
alter table public.transactions enable row level security;

-- users policies
create policy if not exists "select own profile" on public.users
  for select using (auth.uid() = id);

create policy if not exists "insert own profile" on public.users
  for insert with check (auth.uid() = id);

create policy if not exists "update own profile" on public.users
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- rides policies
-- Passengers can see their rides
create policy if not exists "passenger can select own rides" on public.rides
  for select using (auth.uid() = passenger_id);

-- Drivers can see their rides
create policy if not exists "driver can select own rides" on public.rides
  for select using (auth.uid() = driver_id);

-- Any driver can see requested rides to accept
create policy if not exists "driver can see requested rides" on public.rides
  for select using (
    status = 'requested' and exists (
      select 1 from public.users u where u.id = auth.uid() and u.role = 'driver'
    )
  );

-- Passengers can create rides for themselves
create policy if not exists "passenger can insert ride" on public.rides
  for insert with check (auth.uid() = passenger_id);

-- Drivers can accept requested rides and update own rides
create policy if not exists "driver can update to accept/complete" on public.rides
  for update using (
    -- allow updating a requested ride in order to accept it, or any ride already assigned to the driver
    (status = 'requested' and exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'driver'))
    or driver_id = auth.uid()
  )
  with check (
    -- after update, the row must be assigned to the current driver
    driver_id = auth.uid()
  );

-- transactions policies
-- Users can read their own transactions
create policy if not exists "select own transactions" on public.transactions
  for select using (auth.uid() = user_id);

-- No insert/update policies; service role (Edge Functions) bypasses RLS to write

-- RPC to increment token balance
create or replace function public.increment_token_balance(user_id uuid, tokens integer)
returns void
language sql
security definer
as $$
  update public.users
  set token_balance = coalesce(token_balance, 0) + tokens
  where id = user_id;
$$;

-- Optional: allow authenticated users to execute RPC (Edge Function uses service role anyway)
grant execute on function public.increment_token_balance(uuid, integer) to authenticated;

commit;