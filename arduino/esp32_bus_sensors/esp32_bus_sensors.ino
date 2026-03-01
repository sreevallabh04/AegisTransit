/*
 * SMART BUS ACCIDENT DETECTION - ESP32
 * Production-ready: CSV for app import + JSON for Serial Monitor + Buzzer alerts
 *
 * Wiring:
 *   MPU6050: VCC->3.3V, GND->GND, SDA->21, SCL->22 (I2C)
 *   Alcohol sensor: AOUT->GPIO 15 (D15), VCC->3.3V/5V, GND->GND
 *   Buzzer: GPIO 27 (optional)
 *
 * Output 1 - CSV (for app): Log Serial to file in Arduino IDE (Tools -> Log to File).
 *    Format matches app: timestamp,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z,alcohol_ppm,sos_triggered,speed_kmh,event_label
 * Output 2 - JSON: Human-readable in Serial Monitor.
 */

#include <Wire.h>
#include <MPU6050.h>

MPU6050 mpu;

#define ALCOHOL_PIN 15
#define BUZZER_PIN  27

#define BRAKE_THRESHOLD_G    1.5f   // g
#define COLLISION_THRESHOLD_G 2.8f  // g
#define ROLLOVER_GYRO        180   // deg/s
#define ALCOHOL_ADC_THRESHOLD 2000  // raw ADC
#define G_TO_MS2              9.80665f
#define ALCOHOL_ADC_TO_PPM    (500.0f / 4095.0f)  // scale 0-4095 -> 0-500 ppm

unsigned long startMillis = 0;
unsigned long sampleCount = 0;

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("SMART BUS ACCIDENT SYSTEM - CSV + JSON");
  Serial.println("Log this port to file to capture CSV for the app.");

  Wire.begin();
  mpu.initialize();
  if (mpu.testConnection()) {
    Serial.println("MPU6050 OK");
  } else {
    Serial.println("MPU6050 FAIL");
  }

  pinMode(ALCOHOL_PIN, INPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  startMillis = millis();
  // CSV header (app-compatible) - print once
  Serial.println("timestamp,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z,alcohol_ppm,sos_triggered,speed_kmh,event_label");
}

void loop() {
  int16_t ax_raw, ay_raw, az_raw, gx_raw, gy_raw, gz_raw;
  mpu.getMotion6(&ax_raw, &ay_raw, &az_raw, &gx_raw, &gy_raw, &gz_raw);

  float ax_g = ax_raw / 16384.0f;
  float ay_g = ay_raw / 16384.0f;
  float az_g = az_raw / 16384.0f;
  float gx = gx_raw / 131.0f;
  float gy = gy_raw / 131.0f;
  float gz = gz_raw / 131.0f;

  float accelMagnitude_g = sqrt(ax_g*ax_g + ay_g*ay_g + az_g*az_g);
  float accel_x = ax_g * G_TO_MS2;
  float accel_y = ay_g * G_TO_MS2;
  float accel_z = az_g * G_TO_MS2;

  int alcoholRaw = analogRead(ALCOHOL_PIN);
  float alcoholPpm = alcoholRaw * ALCOHOL_ADC_TO_PPM;

  const char* eventLabel = "normal";
  bool alert = false;
  float speedKmh = 40.0f;

  if (accelMagnitude_g > COLLISION_THRESHOLD_G) {
    eventLabel = "collision";
    alert = true;
    speedKmh = 0;
  } else if (accelMagnitude_g > BRAKE_THRESHOLD_G) {
    eventLabel = "sharp_brake";
    alert = true;
    speedKmh = 15.0f;
  }

  if (abs(gx) > ROLLOVER_GYRO || abs(gy) > ROLLOVER_GYRO || abs(gz) > ROLLOVER_GYRO) {
    eventLabel = "rollover";
    alert = true;
    speedKmh = 0;
  }

  bool alcoholDetected = (alcoholRaw > ALCOHOL_ADC_THRESHOLD);
  if (alcoholDetected) alert = true;

  int sosTriggered = 0;  // Set 1 if you add SOS button

  digitalWrite(BUZZER_PIN, alert ? HIGH : LOW);

  if (alert) {
    Serial.println("!!! ALERT !!!");
    Serial.print("Event: "); Serial.println(eventLabel);
    if (alcoholDetected) Serial.println("!!! ALCOHOL DETECTED !!!");
  }

  // --- CSV line (for app import) ---
  unsigned long secs = (millis() - startMillis) / 1000;
  unsigned long h = secs / 3600, m = (secs % 3600) / 60, s = secs % 60;
  char ts[24];
  snprintf(ts, sizeof(ts), "2025-06-15 %02lu:%02lu:%02lu", 8u + (h % 24), m, s);

  Serial.print(ts);
  Serial.print(",");
  Serial.print(accel_x, 2); Serial.print(",");
  Serial.print(accel_y, 2); Serial.print(",");
  Serial.print(accel_z, 2); Serial.print(",");
  Serial.print(gx, 2); Serial.print(",");
  Serial.print(gy, 2); Serial.print(",");
  Serial.print(gz, 2); Serial.print(",");
  Serial.print(alcoholPpm, 1); Serial.print(",");
  Serial.print(sosTriggered); Serial.print(",");
  Serial.print(speedKmh, 1); Serial.print(",");
  Serial.println(eventLabel);

  // --- JSON (Serial Monitor) ---
  Serial.print("{\"ax\":");
  Serial.print(ax_g); Serial.print(",\"ay\":");
  Serial.print(ay_g); Serial.print(",\"az\":");
  Serial.print(az_g); Serial.print(",\"gx\":");
  Serial.print(gx); Serial.print(",\"gy\":");
  Serial.print(gy); Serial.print(",\"gz\":");
  Serial.print(gz); Serial.print(",\"accel_magnitude\":");
  Serial.print(accelMagnitude_g); Serial.print(",\"accident_type\":\"");
  Serial.print(eventLabel); Serial.print("\",\"alcohol_value\":");
  Serial.print(alcoholRaw); Serial.print(",\"alcohol_detected\":");
  Serial.print(alcoholDetected ? "true" : "false");
  Serial.println("}");

  delay(500);
}
