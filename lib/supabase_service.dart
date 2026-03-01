import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';

/// Default trip UUID (must match supabase/schema.sql insert).
const defaultTripId = '00000000-0000-0000-0000-000000000001';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  static String get _tripId => defaultTripId;

  // --- Bus sensor readings ---
  static Future<List<BusSensorReading>> fetchBusSensorReadings({int limit = 500}) async {
    try {
      final res = await _client
          .from('bus_sensor_readings')
          .select()
          .eq('trip_id', _tripId)
          .order('timestamp', ascending: false)
          .limit(limit);
      final list = res as List<dynamic>;
      return list.map((e) => _busFromMap(e as Map<String, dynamic>)).toList().reversed.toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> upsertBusSensorReadings(List<BusSensorReading> readings) async {
    if (readings.isEmpty) return;
    try {
      final rows = readings.map((r) => {
        'trip_id': _tripId,
        'timestamp': r.timestamp.toIso8601String(),
        'accel_x': r.accelX, 'accel_y': r.accelY, 'accel_z': r.accelZ,
        'gyro_x': r.gyroX, 'gyro_y': r.gyroY, 'gyro_z': r.gyroZ,
        'alcohol_ppm': r.alcoholPpm, 'sos_triggered': r.sosTriggered,
        'speed_kmh': r.speedKmh, 'event_label': r.eventLabel,
      }).toList();
      await _client.from('bus_sensor_readings').upsert(rows);
    } catch (_) {}
  }

  static BusSensorReading _busFromMap(Map<String, dynamic> e) {
    final ts = e['timestamp'];
    return BusSensorReading(
      timestamp: ts != null ? DateTime.parse(ts.toString()) : DateTime.now(),
      accelX: _d(e['accel_x']), accelY: _d(e['accel_y']), accelZ: _d(e['accel_z']),
      gyroX: _d(e['gyro_x']), gyroY: _d(e['gyro_y']), gyroZ: _d(e['gyro_z']),
      alcoholPpm: _d(e['alcohol_ppm']),
      sosTriggered: e['sos_triggered'] == true,
      speedKmh: _d(e['speed_kmh']),
      eventLabel: e['event_label']?.toString() ?? 'normal',
    );
  }

  // --- Passenger health readings ---
  static Future<List<PassengerHealthReading>> fetchPassengerHealthReadings({
    String? passengerId,
    int limit = 1000,
  }) async {
    try {
      var query = _client
          .from('passenger_health_readings')
          .select()
          .eq('trip_id', _tripId);
      if (passengerId != null && passengerId.isNotEmpty) {
        query = query.eq('passenger_id', passengerId);
      }
      final res = await query
          .order('timestamp', ascending: true)
          .limit(limit);
      final list = res as List<dynamic>;
      return list.map((e) => _healthFromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> upsertPassengerHealthReadings(List<PassengerHealthReading> readings) async {
    if (readings.isEmpty) return;
    try {
      final rows = readings.map((r) => {
        'trip_id': _tripId,
        'timestamp': r.timestamp.toIso8601String(),
        'seat_number': r.seatNumber, 'passenger_id': r.passengerId, 'passenger_name': r.passengerName,
        'heart_rate_bpm': r.heartRateBpm, 'hrv_ms': r.hrvMs, 'motion_intensity': r.motionIntensity,
        'skin_temp_c': r.skinTempC, 'spo2_percent': r.spo2Percent,
        'existing_condition': r.existingCondition, 'start_dest': r.startDest, 'end_dest': r.endDest,
      }).toList();
      await _client.from('passenger_health_readings').upsert(rows);
    } catch (_) {}
  }

  static PassengerHealthReading _healthFromMap(Map<String, dynamic> e) {
    final ts = e['timestamp'];
    return PassengerHealthReading(
      timestamp: ts != null ? DateTime.parse(ts.toString()) : DateTime.now(),
      seatNumber: e['seat_number']?.toString() ?? '',
      passengerId: e['passenger_id']?.toString() ?? '',
      passengerName: e['passenger_name']?.toString() ?? '',
      heartRateBpm: _i(e['heart_rate_bpm']),
      hrvMs: _d(e['hrv_ms']),
      motionIntensity: _d(e['motion_intensity']),
      skinTempC: _d(e['skin_temp_c']),
      spo2Percent: _i(e['spo2_percent']),
      existingCondition: e['existing_condition']?.toString() ?? '',
      startDest: e['start_dest']?.toString() ?? '',
      endDest: e['end_dest']?.toString() ?? '',
    );
  }

  // --- Passenger assessments ---
  /// If [passengerId] is set, only that passenger's assessments are returned (for passenger view).
  static Future<List<PassengerAssessment>> fetchPassengerAssessments({String? passengerId}) async {
    try {
      var query = _client
          .from('passenger_assessments')
          .select()
          .eq('trip_id', _tripId);
      if (passengerId != null && passengerId.isNotEmpty) {
        query = query.eq('passenger_id', passengerId);
      }
      final res = await query.order('created_at', ascending: false);
      final list = res as List<dynamic>;
      return list.map((e) => _assessmentFromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> insertPassengerAssessments(List<PassengerAssessment> assessments) async {
    if (assessments.isEmpty) return;
    try {
      final rows = assessments.map((a) => {
        'trip_id': _tripId,
        'seat_number': a.seatNumber, 'passenger_id': a.passengerId, 'passenger_name': a.passengerName,
        'status': a.status, 'reasoning': a.reasoning,
      }).toList();
      await _client.from('passenger_assessments').insert(rows);
    } catch (_) {}
  }

  static PassengerAssessment _assessmentFromMap(Map<String, dynamic> e) {
    return PassengerAssessment(
      seatNumber: e['seat_number']?.toString() ?? '',
      passengerId: e['passenger_id']?.toString() ?? '',
      passengerName: e['passenger_name']?.toString() ?? '',
      status: e['status']?.toString() ?? 'Normal',
      reasoning: e['reasoning']?.toString() ?? '',
    );
  }

  // --- Notifications ---
  static Future<List<AppNotification>> fetchNotificationsForPassenger(String passengerId) async {
    try {
      final res = await _client
          .from('notifications')
          .select()
          .eq('passenger_id', passengerId)
          .order('created_at', ascending: false);
      final list = res as List<dynamic>;
      return list.map((e) => _notificationFromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> sendNotification({
    required String passengerId,
    String? seatNumber,
    required String message,
  }) async {
    try {
      await _client.from('notifications').insert({
        'passenger_id': passengerId,
        'seat_number': seatNumber,
        'message': message,
      });
    } catch (_) {}
  }

  static Future<void> markNotificationRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', notificationId);
    } catch (_) {}
  }

  static AppNotification _notificationFromMap(Map<String, dynamic> e) {
    final readAt = e['read_at'];
    final createdAt = e['created_at'];
    return AppNotification(
      id: e['id']?.toString() ?? '',
      passengerId: e['passenger_id']?.toString() ?? '',
      seatNumber: e['seat_number']?.toString(),
      message: e['message']?.toString() ?? '',
      readAt: readAt != null ? DateTime.tryParse(readAt.toString()) : null,
      createdAt: createdAt != null ? DateTime.parse(createdAt.toString()) : DateTime.now(),
    );
  }

  static double _d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
  static int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
