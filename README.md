# Aegis Transit — Public Transport Emergency Intelligence System

**AMD Slingshot Hackathon 2025** · AI for Social Good & Smart Cities

A real-time smart bus safety platform that combines onboard sensors, passenger health data, and **RAG-style AI (Groq)** for emergency triage, fleet control, and passenger notifications — so responders know *who* needs help first when every second counts.

---

## Problem

In bus emergencies (collisions, medical events), drivers and control rooms lack a single view of **who is at risk** and **in what order** to assist. Passenger vitals and bus telemetry are rarely combined for instant triage, and passengers rarely get clear in-app updates from staff.

## Solution

**Aegis Transit** unifies bus sensors (acceleration, gyro, alcohol, SOS) and passenger health (HR, SpO2, HRV, motion) in one app, with:

- **Passenger app** — Check-in by seat, view your own vitals and bus status, receive staff notifications.
- **Admin / Fleet Control** — See all passengers, run AI triage (Critical / Panic / Normal + priority order), ask natural-language questions (“Who is critical?”, “How is person A?”) answered from live context (RAG), send in-app notifications, and view time-series charts (HR, SpO2, HRV, motion).

Data flows through **Supabase** (RLS-secured); AI uses **Groq** with retrieved context so answers stay grounded in current data. No secrets in the repo — keys via `.env` or `--dart-define`.

---

## Innovation Themes (AMD Slingshot)

| Theme | How we fit |
|-------|------------|
| **AI for Social Good** | Faster, data-driven emergency response and clearer passenger communication during incidents. |
| **AI for Smart Cities** | Scalable pattern for buses, ferries, or shared transport with real-time fleet and passenger intelligence. |

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **App** | Flutter (Dart), Material 3, fl_chart |
| **Backend** | Supabase (PostgreSQL, RLS, optional Realtime) |
| **AI** | Groq API — RAG-style prompts (retrieve bus + passenger context → generate triage & Q&A) |
| **Hardware (optional)** | ESP32 + MPU6050 (IMU), MQ-3 (alcohol), SOS button; Bluetooth (Flutter Blue Plus) or CSV import |

---

## Architecture (high level)

1. **Edge / bus** — ESP32 (or CSV) → bus sensor readings; passenger vitals from wearables/CSV.
2. **Sync** — Flutter app uploads to Supabase (`bus_sensor_readings`, `passenger_health_readings`).
3. **AI** — Groq: build context from Supabase (bus summary + per-passenger vitals/assessments), fixed system prompt (“answer only from context”), user prompt = context + question/analysis request.
4. **Roles** — Passenger: own data only. Admin: full fleet view, charts, notify, RAG Q&A.
5. **Security** — Anon key in client; RLS and optional Supabase Auth for admin; no service role in app.

---

## Screens

| Flow | Screens |
|------|--------|
| **Passenger** | Login (warm UI) → Setup (seat, ID, CSV/import) → Dashboard (bus + own health, Run AI, notifications) → Health Details, Emergency (own status only) |
| **Admin** | Admin Login (control-room UI) → Bus Overview (seat-wise health, Notify) → Passenger sensor charts (HR, SpO2, HRV, motion) → RAG Q&A (Groq) |

---

## Run locally

```bash
flutter pub get
flutter run
```

**Secrets (repo is GitHub-safe):** Copy `.env.example` to `.env`, add your keys, then:

- **Windows:** `.\run_with_env.bat`
- **Or:** `flutter run --dart-define=GROQ_API_KEY=... --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

Without keys, the app still runs (CSV fallback; Groq key can be entered in Setup).

- **Groq:** [console.groq.com](https://console.groq.com)  
- **Supabase:** [supabase.com](https://supabase.com) → New project → run `supabase/schema.sql` in SQL Editor → use URL + anon key from Settings → API.

---

## Hardware (ESP32) — optional

| ESP32 Pin | Component |
|-----------|-----------|
| GPIO 21 (SDA), 22 (SCL), 3.3V | MPU6050 (IMU) |
| GPIO 34 (ADC), 5V | MQ-3 (alcohol) |
| GPIO 15 | SOS button (INPUT_PULLUP) |

Firmware: `arduino/esp32_bus_sensors/esp32_bus_sensors.ino`. Alternatively use CSV files in `assets/data/` (see `assets/data/README_CSV_FORMATS.md`).

---

## Impact

- **Safer trips** — Real-time view of who is at risk and in what order during accidents or medical events.
- **Smarter decisions** — AI triage and natural-language Q&A reduce guesswork when time is critical.
- **Better communication** — Passengers get official in-app notifications instead of word-of-mouth.
- **Scalable & secure** — Supabase + RLS; same pattern can extend to trains, ferries, and other shared transport.

---

## Team

**AMD Slingshot 2025**  
Tanguturi Sharani · Sreevallabh

---

## License

See repository for license details.
