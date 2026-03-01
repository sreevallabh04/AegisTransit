-- Run this in Supabase Dashboard -> SQL Editor
-- Smart Bus: trips, bus_sensor_readings, passenger_health_readings, passenger_assessments, notifications

create table if not exists trips (
  id uuid primary key default gen_random_uuid(),
  name text,
  created_at timestamptz default now()
);

create table if not exists bus_sensor_readings (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references trips(id),
  timestamp timestamptz not null,
  accel_x float8, accel_y float8, accel_z float8,
  gyro_x float8, gyro_y float8, gyro_z float8,
  alcohol_ppm float8, sos_triggered boolean default false,
  speed_kmh float8, event_label text
);

create table if not exists passenger_health_readings (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references trips(id),
  timestamp timestamptz not null,
  seat_number text, passenger_id text, passenger_name text,
  heart_rate_bpm int, hrv_ms float8, motion_intensity float8,
  skin_temp_c float8, spo2_percent int, existing_condition text,
  start_dest text, end_dest text
);

create table if not exists passenger_assessments (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references trips(id),
  seat_number text, passenger_id text, passenger_name text,
  status text, reasoning text, created_at timestamptz default now()
);

create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  passenger_id text not null,
  seat_number text,
  message text not null,
  read_at timestamptz,
  created_at timestamptz default now()
);

-- Optional: insert default trip
insert into trips (id, name) values (
  '00000000-0000-0000-0000-000000000001'::uuid,
  'Default Trip'
) on conflict do nothing;

-- RLS: enable on tables that need row-level security
alter table passenger_health_readings enable row level security;
alter table notifications enable row level security;
alter table bus_sensor_readings enable row level security;
alter table passenger_assessments enable row level security;

-- Allow all for anon for now (app uses anon key; restrict by trip_id or auth in app logic)
-- For production, add policies: e.g. select where trip_id = current_trip() or auth.role() = 'admin'
create policy "Allow read bus_sensor_readings" on bus_sensor_readings for select using (true);
create policy "Allow insert bus_sensor_readings" on bus_sensor_readings for insert with check (true);
create policy "Allow read passenger_health_readings" on passenger_health_readings for select using (true);
create policy "Allow insert passenger_health_readings" on passenger_health_readings for insert with check (true);
create policy "Allow read passenger_assessments" on passenger_assessments for select using (true);
create policy "Allow insert passenger_assessments" on passenger_assessments for insert with check (true);
create policy "Allow read notifications" on notifications for select using (true);
create policy "Allow insert notifications" on notifications for insert with check (true);
create policy "Allow update notifications" on notifications for update using (true);
