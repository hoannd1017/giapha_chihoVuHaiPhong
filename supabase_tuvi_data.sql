-- Run this in Supabase SQL editor to enable TuVi cloud sync/backup.
create table if not exists public.tuvi_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data text not null default '',
  updated_at timestamptz not null default now()
);

alter table public.tuvi_data enable row level security;

drop policy if exists "tuvi_data_select_own" on public.tuvi_data;
create policy "tuvi_data_select_own" on public.tuvi_data
  for select using (auth.uid() = user_id);

drop policy if exists "tuvi_data_insert_own" on public.tuvi_data;
create policy "tuvi_data_insert_own" on public.tuvi_data
  for insert with check (auth.uid() = user_id);

drop policy if exists "tuvi_data_update_own" on public.tuvi_data;
create policy "tuvi_data_update_own" on public.tuvi_data
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "tuvi_data_delete_own" on public.tuvi_data;
create policy "tuvi_data_delete_own" on public.tuvi_data
  for delete using (auth.uid() = user_id);

drop policy if exists "tuvi_data_select_admin" on public.tuvi_data;
create policy "tuvi_data_select_admin"
  on public.tuvi_data for select
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

drop policy if exists "tuvi_data_delete_admin" on public.tuvi_data;
create policy "tuvi_data_delete_admin"
  on public.tuvi_data for delete
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));
