# Smart Bus Accident & Passenger Health Monitoring System
**Public Transport Emergency Intelligence System with Gemini AI**

ECE3502 - IoT Domain Analyst | Team: Tanguturi Sharani (22MIS1154) & Sreevallabh (22MIS1170)

## What This Is
A Flutter-based smart transportation safety system that:
- Reads **bus sensor data** (accelerometer, gyroscope, alcohol, SOS) from CSV files (simulating ESP32 hardware)
- Reads **passenger health data** (heart rate, HRV, SpO2, motion) from CSV files (simulating smartwatch readings)
- Uses **Google Gemini AI API** to classify each passenger as Normal / Panic / Critical
- Provides **real-time analytics** with interactive charts (acceleration timeline, heart rate trends, severity distribution)
- Generates **emergency severity reports** for prioritized medical response

## Architecture (4-Layer)
1. **Bus Accident Detection** — ESP32 + MPU6050 (IMU) + MQ-3 (Alcohol) + SOS Button
2. **Passenger Health Monitoring** — Smartwatch sensors (HR, HRV, SpO2, motion)
3. **AI Intelligence Layer** — Google Gemini 2.0 Flash API (replaces local LLM for speed)
4. **Emergency Response** — Structured severity reports with passenger-wise triage

## Hardware Connections (ESP32)
| ESP32 Pin | Component | Connection |
|-----------|-----------|------------|
| GPIO 21 (SDA) | MPU6050 | SDA |
| GPIO 22 (SCL) | MPU6050 | SCL |
| 3.3V | MPU6050 | VCC |
| GPIO 34 (ADC) | MQ-3 Alcohol | AO (Analog) |
| 5V (VIN) | MQ-3 Alcohol | VCC |
| GPIO 15 | SOS Button | Terminal 1 (INPUT_PULLUP) |
| GND | All | GND |

## CSV Datasets (in `assets/data/`)
- `bus_sensor_data.csv` — 40 readings: normal driving → sharp brake → collision → post-impact → SOS
- `passenger_health_data.csv` — 48 readings: 6 passengers × 8 time points (pre/during/post accident)

## Screens
1. **Login** — Passenger registration (seat, ID, health conditions, route)
2. **Setup** — CSV data loading + Gemini API key entry
3. **Dashboard** — Live status, AI analysis trigger, bus/health status
4. **Health Details** — Per-passenger metrics with line charts (HR, HRV trends)
5. **Emergency Alert** — Red alert UI with passenger severity report
6. **Admin Overview** — All passengers seat-wise with AI assessments
7. **Analytics** — Acceleration timeline, HR comparison, severity pie chart, speed chart

## Run
```bash
flutter pub get
flutter run
```

## Secrets (GitHub‑publishable)
API keys and Supabase credentials are **not** stored in the repo. Use either:

1. **`.env` file (recommended for local dev)**  
   - Copy `.env.example` to `.env`  
   - Add your keys (Groq, Supabase URL, Supabase anon key)  
   - Run: `.\run_with_env.bat` (Windows) or `flutter run` with the script that passes `--dart-define` from `.env`

2. **`--dart-define`**  
   ```bash
   flutter run --dart-define=GROQ_API_KEY=your_groq_key --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
   ```

If Supabase or Groq keys are missing, the app still runs: it uses CSV fallback and you can enter the Groq key in the Setup screen.

- **Groq API key:** [console.groq.com](https://console.groq.com)  
- **Supabase:** create a project at [supabase.com](https://supabase.com), run `supabase/schema.sql` in the SQL Editor, then use Settings → API → URL and anon key.
