import 'dart:math';

class BusSensorReading {
  final DateTime timestamp;
  final double accelX, accelY, accelZ;
  final double gyroX, gyroY, gyroZ;
  final double alcoholPpm;
  final bool sosTriggered;
  final double speedKmh;
  final String eventLabel;

  BusSensorReading({
    required this.timestamp,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.alcoholPpm,
    required this.sosTriggered,
    required this.speedKmh,
    required this.eventLabel,
  });

  double get accelMagnitude =>
      sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);

  double get gyroMagnitude =>
      sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ);

  bool get isAccidentEvent =>
      eventLabel == 'collision' ||
      eventLabel == 'sharp_brake' ||
      eventLabel == 'post_impact' ||
      eventLabel == 'rollover';
}

class PassengerHealthReading {
  final DateTime timestamp;
  final String seatNumber;
  final String passengerId;
  final String passengerName;
  final int heartRateBpm;
  final double hrvMs;
  final double motionIntensity;
  final double skinTempC;
  final int spo2Percent;
  final String existingCondition;
  final String startDest;
  final String endDest;

  PassengerHealthReading({
    required this.timestamp,
    required this.seatNumber,
    required this.passengerId,
    required this.passengerName,
    required this.heartRateBpm,
    required this.hrvMs,
    required this.motionIntensity,
    required this.skinTempC,
    required this.spo2Percent,
    required this.existingCondition,
    required this.startDest,
    required this.endDest,
  });
}

class PassengerAssessment {
  final String seatNumber;
  final String passengerId;
  final String passengerName;
  final String status;
  final String reasoning;

  PassengerAssessment({
    required this.seatNumber,
    required this.passengerId,
    required this.passengerName,
    required this.status,
    required this.reasoning,
  });
}

class AppNotification {
  final String id;
  final String passengerId;
  final String? seatNumber;
  final String message;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.passengerId,
    this.seatNumber,
    required this.message,
    this.readAt,
    required this.createdAt,
  });
  bool get isUnread => readAt == null;
}
