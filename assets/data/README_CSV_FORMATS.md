# CSV Data Formats for Smart Bus App

Two CSV types are supported for production and demo.

---

## 1. Bus / ESP32 sensor CSV

**Use:** Accident detection (MPU6050 + alcohol sensor). From Arduino Serial log or BLE stream.

| Column           | Type    | Example        | Description                    |
|------------------|---------|----------------|--------------------------------|
| timestamp        | datetime| 2025-06-15 08:00:00 | ISO-style date-time        |
| accel_x          | float   | -0.39          | Acceleration X (m/s²)         |
| accel_y          | float   | -0.01          | Acceleration Y (m/s²)         |
| accel_z          | float   | -9.61          | Acceleration Z (m/s²)         |
| gyro_x           | float   | 3.82           | Gyro X (deg/s)                |
| gyro_y           | float   | 4.64           | Gyro Y (deg/s)                |
| gyro_z           | float   | -1.44          | Gyro Z (deg/s)                |
| alcohol_ppm      | float   | 217.0          | Alcohol (0–500 ppm scale)     |
| sos_triggered    | 0/1     | 0              | SOS button pressed            |
| speed_kmh        | float   | 40.0           | Speed (km/h)                  |
| event_label      | string  | normal         | normal, sharp_brake, collision, rollover |

**How to get this CSV from ESP32:**
- Upload `arduino/esp32_bus_sensors/esp32_bus_sensors.ino`.
- In Arduino IDE: **Tools → Serial Monitor** (115200). Then **Tools → Log to File** and choose a `.csv` file.
- The sketch prints a header line first, then one CSV data line every 500 ms. Save the log and use it in the app via **Setup → Import CSV files**.

---

## 2. Passenger health CSV

**Use:** Heart rate, HRV, SpO2, motion per passenger (e.g. from wearables or simulated data).

| Column             | Type   | Example              |
|--------------------|--------|----------------------|
| timestamp          | datetime | 2025-06-15 08:00:00 |
| seat_number        | string | A01                   |
| passenger_id       | string | P-001                 |
| passenger_name     | string | Riya Sharma          |
| heart_rate_bpm     | int    | 72                    |
| hrv_ms             | float  | 48                    |
| motion_intensity   | float  | 0.30                  |
| skin_temp_c        | float  | 36.5                  |
| spo2_percent       | int    | 98                    |
| existing_condition | string | None                  |
| start_dest         | string | City Center           |
| end_dest           | string | University Gate       |

---

## App flow

1. **Setup** → **Import CSV files (ESP32 + Passenger)**.
2. For each type: **Pick file** (or paste CSV), check preview, then **Use this data in app**.
3. Or use **Use demo data from app assets** to load built-in samples.
4. **Continue to Dashboard** to see analytics and run AI assessment.
