export interface BusSensorReading {
  timestamp: string;
  accelX: number;
  accelY: number;
  accelZ: number;
  gyroX: number;
  gyroY: number;
  gyroZ: number;
  alcoholPpm: number;
  sosTriggered: boolean;
  speedKmh: number;
  eventLabel: string;
}

export interface PassengerHealthReading {
  timestamp: string;
  seatNumber: string;
  passengerId: string;
  passengerName: string;
  heartRateBpm: number;
  hrvMs: number;
  motionIntensity: number;
  skinTempC: number;
  spo2Percent: number;
  existingCondition: string;
  startDest: string;
  endDest: string;
}

// Sample bus sensor data (matches Flutter app CSV)
export const busSensorData: BusSensorReading[] = [
  { timestamp: "2025-06-15 08:00:00", accelX: 0.15, accelY: -0.08, accelZ: 9.79, gyroX: 0.5, gyroY: -0.3, gyroZ: 0.2, alcoholPpm: 0, sosTriggered: false, speedKmh: 42, eventLabel: "normal" },
  { timestamp: "2025-06-15 08:00:15", accelX: 0.22, accelY: -0.12, accelZ: 9.8, gyroX: 0.8, gyroY: -0.5, gyroZ: 0.4, alcoholPpm: 0, sosTriggered: false, speedKmh: 44, eventLabel: "normal" },
  { timestamp: "2025-06-15 08:01:00", accelX: 0.25, accelY: -0.1, accelZ: 9.82, gyroX: 0.9, gyroY: -0.6, gyroZ: 0.5, alcoholPpm: 0, sosTriggered: false, speedKmh: 46, eventLabel: "normal" },
  { timestamp: "2025-06-15 08:02:00", accelX: 0.14, accelY: -0.09, accelZ: 9.8, gyroX: 0.4, gyroY: -0.3, gyroZ: 0.2, alcoholPpm: 0, sosTriggered: false, speedKmh: 44, eventLabel: "normal" },
  { timestamp: "2025-06-15 08:03:00", accelX: 0.12, accelY: -0.06, accelZ: 9.8, gyroX: 0.5, gyroY: -0.3, gyroZ: 0.2, alcoholPpm: 0, sosTriggered: false, speedKmh: 45, eventLabel: "normal" },
  { timestamp: "2025-06-15 08:04:30", accelX: 0.32, accelY: -0.2, accelZ: 9.8, gyroX: 1.2, gyroY: -0.9, gyroZ: 0.8, alcoholPpm: 0, sosTriggered: false, speedKmh: 50, eventLabel: "normal" },
  { timestamp: "2025-06-15 08:05:00", accelX: 1.8, accelY: -0.95, accelZ: 9.85, gyroX: 3.2, gyroY: -2.5, gyroZ: 1.8, alcoholPpm: 0, sosTriggered: false, speedKmh: 35, eventLabel: "sharp_brake" },
  { timestamp: "2025-06-15 08:05:05", accelX: 4.5, accelY: -2.3, accelZ: 12.6, gyroX: 18, gyroY: -12, gyroZ: 8.5, alcoholPpm: 0, sosTriggered: false, speedKmh: 18, eventLabel: "sharp_brake" },
  { timestamp: "2025-06-15 08:05:10", accelX: 12.5, accelY: 6.3, accelZ: 18.4, gyroX: 55, gyroY: 38, gyroZ: 22, alcoholPpm: 0, sosTriggered: false, speedKmh: 5, eventLabel: "collision" },
  { timestamp: "2025-06-15 08:05:15", accelX: 8.2, accelY: -4.8, accelZ: 15.2, gyroX: 35, gyroY: -25, gyroZ: 18, alcoholPpm: 0, sosTriggered: false, speedKmh: 0, eventLabel: "collision" },
  { timestamp: "2025-06-15 08:06:00", accelX: 0.2, accelY: -0.1, accelZ: 9.8, gyroX: 0.3, gyroY: -0.2, gyroZ: 0.1, alcoholPpm: 0, sosTriggered: false, speedKmh: 0, eventLabel: "post_impact" },
];

// Sample passenger health (latest per passenger for overview)
export const passengerHealthData: PassengerHealthReading[] = [
  { timestamp: "2025-06-15 08:07:00", seatNumber: "A01", passengerId: "P-001", passengerName: "Riya Sharma", heartRateBpm: 85, hrvMs: 35, motionIntensity: 0.8, skinTempC: 36.6, spo2Percent: 98, existingCondition: "None", startDest: "City Center", endDest: "University Gate" },
  { timestamp: "2025-06-15 08:07:00", seatNumber: "A02", passengerId: "P-002", passengerName: "Karthik Reddy", heartRateBpm: 105, hrvMs: 22, motionIntensity: 1.2, skinTempC: 36.8, spo2Percent: 94, existingCondition: "Asthma", startDest: "Bus Depot", endDest: "Tech Park" },
  { timestamp: "2025-06-15 08:07:00", seatNumber: "A03", passengerId: "P-003", passengerName: "Priya Nair", heartRateBpm: 78, hrvMs: 48, motionIntensity: 0.4, skinTempC: 36.5, spo2Percent: 99, existingCondition: "None", startDest: "Mall", endDest: "Hospital" },
  { timestamp: "2025-06-15 08:07:00", seatNumber: "B01", passengerId: "P-004", passengerName: "Vikram Singh", heartRateBpm: 95, hrvMs: 30, motionIntensity: 0.9, skinTempC: 36.6, spo2Percent: 96, existingCondition: "None", startDest: "Station", endDest: "Airport" },
  { timestamp: "2025-06-15 08:07:00", seatNumber: "B02", passengerId: "P-005", passengerName: "Anita Desai", heartRateBpm: 88, hrvMs: 42, motionIntensity: 0.6, skinTempC: 36.5, spo2Percent: 98, existingCondition: "Hypertension", startDest: "School", endDest: "Market" },
  { timestamp: "2025-06-15 08:07:00", seatNumber: "B03", passengerId: "P-006", passengerName: "Rahul Mehta", heartRateBpm: 72, hrvMs: 52, motionIntensity: 0.3, skinTempC: 36.4, spo2Percent: 99, existingCondition: "None", startDest: "Office", endDest: "Home" },
];

export function getAccelMagnitude(r: BusSensorReading): number {
  return Math.sqrt(r.accelX * r.accelX + r.accelY * r.accelY + r.accelZ * r.accelZ);
}

export function getEventCounts(data: BusSensorReading[]) {
  const counts: Record<string, number> = {};
  data.forEach((r) => {
    counts[r.eventLabel] = (counts[r.eventLabel] ?? 0) + 1;
  });
  return counts;
}
