import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'supabase_service.dart';

class CsvDataService {
  static Future<List<BusSensorReading>> loadBusSensorData() async {
    final raw = await rootBundle.loadString('assets/data/bus_sensor_data.csv');
    final rows = const CsvToListConverter().convert(raw, eol: '\n');
    return rows.skip(1).where((r) => r.length >= 11).map((r) {
      return BusSensorReading(
        timestamp: DateTime.parse(r[0].toString().trim()),
        accelX: _d(r[1]),
        accelY: _d(r[2]),
        accelZ: _d(r[3]),
        gyroX: _d(r[4]),
        gyroY: _d(r[5]),
        gyroZ: _d(r[6]),
        alcoholPpm: _d(r[7]),
        sosTriggered: r[8].toString().trim() == '1',
        speedKmh: _d(r[9]),
        eventLabel: r[10].toString().trim(),
      );
    }).toList();
  }

  static Future<List<PassengerHealthReading>> loadPassengerHealthData() async {
    final raw =
        await rootBundle.loadString('assets/data/passenger_health_data.csv');
    final rows = const CsvToListConverter().convert(raw, eol: '\n');
    return rows.skip(1).where((r) => r.length >= 12).map((r) {
      return PassengerHealthReading(
        timestamp: DateTime.parse(r[0].toString().trim()),
        seatNumber: r[1].toString().trim(),
        passengerId: r[2].toString().trim(),
        passengerName: r[3].toString().trim(),
        heartRateBpm: _i(r[4]),
        hrvMs: _d(r[5]),
        motionIntensity: _d(r[6]),
        skinTempC: _d(r[7]),
        spo2Percent: _i(r[8]),
        existingCondition: r[9].toString().trim(),
        startDest: r[10].toString().trim(),
        endDest: r[11].toString().trim(),
      );
    }).toList();
  }

  static double _d(dynamic v) => double.tryParse(v.toString().trim()) ?? 0.0;
  static int _i(dynamic v) => int.tryParse(v.toString().trim()) ?? 0;

  /// Parse one CSV line from ESP32 (timestamp,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z,alcohol_ppm,sos_triggered,speed_kmh,event_label).
  static BusSensorReading? parseBusSensorLine(String line) {
    final row = const CsvToListConverter().convert('$line\n');
    if (row.isEmpty) return null;
    final r = row.first;
    if (r.length < 11) return null;
    return BusSensorReading(
      timestamp: DateTime.tryParse(r[0].toString().trim()) ?? DateTime.now(),
      accelX: _d(r[1]),
      accelY: _d(r[2]),
      accelZ: _d(r[3]),
      gyroX: _d(r[4]),
      gyroY: _d(r[5]),
      gyroZ: _d(r[6]),
      alcoholPpm: _d(r[7]),
      sosTriggered: r[8].toString().trim() == '1',
      speedKmh: _d(r[9]),
      eventLabel: r[10].toString().trim(),
    );
  }

  /// Bus/ESP32 CSV: header + data rows. Returns data and any parse errors.
  static ({List<BusSensorReading> data, List<String> errors}) parseBusSensorCsv(String raw) {
    final errors = <String>[];
    final rows = const CsvToListConverter().convert(raw, eol: '\n');
    if (rows.isEmpty) {
      return (data: [], errors: ['Empty file']);
    }
    final data = <BusSensorReading>[];
    final skipHeader = rows.length > 1 &&
        rows.first.isNotEmpty &&
        rows.first[0].toString().toLowerCase().contains('timestamp');
    final start = skipHeader ? 1 : 0;
    for (var i = start; i < rows.length; i++) {
      final r = rows[i];
      if (r.length < 11) {
        errors.add('Row ${i + 1}: expected 11 columns, got ${r.length}');
        continue;
      }
      try {
        data.add(BusSensorReading(
          timestamp: DateTime.tryParse(r[0].toString().trim()) ?? DateTime.now(),
          accelX: _d(r[1]),
          accelY: _d(r[2]),
          accelZ: _d(r[3]),
          gyroX: _d(r[4]),
          gyroY: _d(r[5]),
          gyroZ: _d(r[6]),
          alcoholPpm: _d(r[7]),
          sosTriggered: r[8].toString().trim() == '1',
          speedKmh: _d(r[9]),
          eventLabel: r[10].toString().trim(),
        ));
      } catch (e) {
        errors.add('Row ${i + 1}: $e');
      }
    }
    return (data: data, errors: errors);
  }

  /// Passenger health CSV: header + data rows.
  static ({List<PassengerHealthReading> data, List<String> errors}) parsePassengerHealthCsv(String raw) {
    final errors = <String>[];
    final rows = const CsvToListConverter().convert(raw, eol: '\n');
    if (rows.isEmpty) {
      return (data: [], errors: ['Empty file']);
    }
    final data = <PassengerHealthReading>[];
    final skipHeader = rows.length > 1 &&
        rows.first.isNotEmpty &&
        rows.first[0].toString().toLowerCase().contains('timestamp');
    final start = skipHeader ? 1 : 0;
    for (var i = start; i < rows.length; i++) {
      final r = rows[i];
      if (r.length < 12) {
        errors.add('Row ${i + 1}: expected 12 columns, got ${r.length}');
        continue;
      }
      try {
        data.add(PassengerHealthReading(
          timestamp: DateTime.tryParse(r[0].toString().trim()) ?? DateTime.now(),
          seatNumber: r[1].toString().trim(),
          passengerId: r[2].toString().trim(),
          passengerName: r[3].toString().trim(),
          heartRateBpm: _i(r[4]),
          hrvMs: _d(r[5]),
          motionIntensity: _d(r[6]),
          skinTempC: _d(r[7]),
          spo2Percent: _i(r[8]),
          existingCondition: r[9].toString().trim(),
          startDest: r[10].toString().trim(),
          endDest: r[11].toString().trim(),
        ));
      } catch (e) {
        errors.add('Row ${i + 1}: $e');
      }
    }
    return (data: data, errors: errors);
  }

  static const busCsvHeader =
      'timestamp,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z,alcohol_ppm,sos_triggered,speed_kmh,event_label';
  static const passengerCsvHeader =
      'timestamp,seat_number,passenger_id,passenger_name,heart_rate_bpm,hrv_ms,motion_intensity,skin_temp_c,spo2_percent,existing_condition,start_dest,end_dest';
}

class GroqAiService {
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  /// RAG: Build retrieved context string from bus + health + assessments (single source for all prompts).
  static String buildRagContext({
    required List<BusSensorReading> busSensorData,
    required List<PassengerHealthReading> healthData,
    required List<PassengerAssessment> assessments,
  }) {
    final buf = StringBuffer();
    final collisions =
        busSensorData.where((r) => r.eventLabel == 'collision').toList();
    final maxAccel = collisions.isNotEmpty
        ? collisions.map((r) => r.accelMagnitude).reduce(max)
        : 0.0;
    buf
      ..writeln('## Bus incident context')
      ..writeln('A bus ${collisions.isNotEmpty ? "collision has occurred" : "is in normal operation"}. Maximum impact: ${maxAccel.toStringAsFixed(1)} m/s² acceleration.')
      ..writeln()
      ..writeln('## Passenger vitals and assessments');
    final passengers = <String, List<PassengerHealthReading>>{};
    for (final r in healthData) {
      passengers.putIfAbsent(r.passengerId, () => []).add(r);
    }
    var personLetter = 'A';
    final sortedEntries = passengers.entries.toList()
      ..sort((a, b) => (a.value.last.seatNumber).compareTo(b.value.last.seatNumber));
    for (final entry in sortedEntries) {
      final readings = entry.value;
      final baseline = readings.first;
      final latest = readings.last;
      PassengerAssessment? assessment;
      for (final a in assessments) {
        if (a.seatNumber == latest.seatNumber) {
          assessment = a;
          break;
        }
      }
      buf
        ..writeln('• Person $personLetter = ${latest.passengerName} (Seat ${latest.seatNumber}, ID ${latest.passengerId})')
        ..writeln('  Pre-existing: ${latest.existingCondition}')
        ..writeln('  Baseline HR: ${baseline.heartRateBpm} bpm -> Current: ${latest.heartRateBpm} bpm')
        ..writeln('  Baseline HRV: ${baseline.hrvMs} ms -> Current: ${latest.hrvMs} ms')
        ..writeln('  Motion: ${latest.motionIntensity} (baseline: ${baseline.motionIntensity}), SpO2: ${latest.spo2Percent}%, Skin temp: ${latest.skinTempC} C');
      if (assessment != null) {
        buf.writeln('  AI status: ${assessment.status}. ${assessment.reasoning}');
      }
      buf.writeln();
      personLetter = String.fromCharCode(personLetter.codeUnitAt(0) + 1);
    }
    return buf.toString();
  }

  static const _systemTriage = "You are a medical triage AI for a smart bus emergency response system. "
      "Answer ONLY from the provided context. Do not infer or add information not in the context. "
      "Respond with valid JSON only, no markdown or extra text.";
  static const _systemQA = "You are an AI assistant for a smart bus emergency response system. "
      "Answer ONLY from the provided context. Do not infer or add information not in the context. "
      "Be concise. When citing data, refer to seat or person (e.g. 'Based on seat A01 vitals...').";

  static Future<Map<String, dynamic>> analyzePassengers({
    required String apiKey,
    required List<BusSensorReading> busSensorData,
    required List<PassengerHealthReading> healthData,
  }) async {
    final context = buildRagContext(
      busSensorData: busSensorData,
      healthData: healthData,
      assessments: [],
    );
    const instruction = 'Analyze each passenger in the context and classify as Normal, Panic, or Critical. '
        'Respond ONLY with valid JSON in this exact format:\n'
        '{"assessments": [{"seat": "A01", "passenger_id": "P-001", "name": "Name", "status": "Normal|Panic|Critical", "reasoning": "One sentence"}], '
        '"emergency_summary": "Overall 2-3 sentence summary", '
        '"recommended_priority": ["seat numbers by urgency"]}';
    final userContent = 'Context:\n$context\n\nInstruction: $instruction';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': _systemTriage},
          {'role': 'user', 'content': userContent},
        ],
        'temperature': 0.2,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error ${response.statusCode}: ${response.body}');
    }

    final data = _parseGroqResponse(response.body);
    final choices = data['choices'];
    if (choices == null || choices is! List || choices.isEmpty) {
      throw Exception('Groq API returned no choices. Response: ${response.body}');
    }
    final content = choices[0]['message']?['content'];
    if (content == null || content is! String) {
      throw Exception('Groq API returned invalid content. Response: ${response.body}');
    }
    return _parseJsonFromContent(content);
  }

  /// Parse API response body: trim, strip BOM, handle error payload.
  static Map<String, dynamic> _parseGroqResponse(String body) {
    final raw = body.trim().replaceFirst(RegExp(r'^\uFEFF'), '');
    if (raw.isEmpty) {
      throw Exception('Groq API returned empty response');
    }
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final err = data['error'];
      if (err != null) {
        final msg = err is Map ? (err['message'] ?? err).toString() : err.toString();
        throw Exception('Groq API error: $msg');
      }
      return data;
    } on FormatException catch (e) {
      throw Exception('Groq API returned invalid JSON (${e.message}): ${raw.length > 100 ? '${raw.substring(0, 100)}...' : raw}');
    }
  }

  /// Extract and parse JSON from model content (may be wrapped in markdown or have leading text).
  static Map<String, dynamic> _parseJsonFromContent(String content) {
    String raw = content.trim();
    if (raw.isEmpty) {
      throw Exception('AI returned empty content');
    }
    // Strip optional markdown code block
    final codeBlockMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(raw);
    if (codeBlockMatch != null) {
      raw = codeBlockMatch.group(1)?.trim() ?? raw;
    }
    // If still doesn't start with '{', find first { and last }
    if (!raw.startsWith('{')) {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start >= 0 && end > start) {
        raw = raw.substring(start, end + 1);
      }
    }
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw Exception('AI returned invalid JSON (${e.message}). Content starts with: ${raw.length > 80 ? '${raw.substring(0, 80)}...' : raw}');
    }
  }

  /// RAG Q&A: answers questions about passengers using retrieved context.
  static Future<String> askAboutPassengers({
    required String apiKey,
    required String question,
    required List<PassengerHealthReading> healthData,
    required List<PassengerAssessment> assessments,
    required bool hasAccident,
    required List<BusSensorReading> busSensorData,
  }) async {
    final context = buildRagContext(
      busSensorData: busSensorData,
      healthData: healthData,
      assessments: assessments,
    );
    final userContent = 'Context (reference: Person A = seat A01, Person B = A02, Person C = A03, etc.):\n\n$context\n\nQuestion from admin: $question';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': _systemQA},
          {'role': 'user', 'content': userContent},
        ],
        'temperature': 0.3,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error ${response.statusCode}: ${response.body}');
    }

    final data = _parseGroqResponse(response.body);
    final choices = data['choices'];
    if (choices == null || choices is! List || choices.isEmpty) {
      throw Exception('Groq API returned no choices.');
    }
    final content = choices[0]['message']?['content'];
    if (content == null || content is! String) {
      throw Exception('Groq API returned invalid content.');
    }
    return content;
  }
}


class AppState {
  static final AppState instance = AppState._();
  AppState._();

  List<BusSensorReading> busSensorData = [];
  List<PassengerHealthReading> passengerHealthData = [];
  List<PassengerAssessment> assessments = [];
  bool isDataLoaded = false;
  bool isAnalyzing = false;
  String? groqApiKey;
  String? emergencySummary;
  List<String>? recommendedPriority;
  String? errorMessage;

  String currentSeat = 'B12';
  String currentPassengerId = 'P-012';
  String currentPassengerName = 'Alex Kumar';

  /// True after admin logs in; cleared on admin logout. Used for route guards and theme.
  bool isAdminSession = false;

  Future<void> loadData() async {
    try {
      final bus = await SupabaseService.fetchBusSensorReadings();
      final health = isAdminSession
          ? await SupabaseService.fetchPassengerHealthReadings()
          : await SupabaseService.fetchPassengerHealthReadings(passengerId: currentPassengerId);
      final assess = isAdminSession
          ? await SupabaseService.fetchPassengerAssessments()
          : await SupabaseService.fetchPassengerAssessments(passengerId: currentPassengerId);
      if (bus.isNotEmpty || health.isNotEmpty) {
        busSensorData = bus;
        passengerHealthData = health;
        assessments = assess;
        isDataLoaded = true;
        return;
      }
    } catch (_) {}
    busSensorData = await CsvDataService.loadBusSensorData();
    passengerHealthData = await CsvDataService.loadPassengerHealthData();
    if (!isAdminSession && passengerHealthData.isNotEmpty) {
      passengerHealthData = passengerHealthData.where((r) => r.passengerId == currentPassengerId).toList();
    }
    assessments = isAdminSession
        ? await SupabaseService.fetchPassengerAssessments()
        : await SupabaseService.fetchPassengerAssessments(passengerId: currentPassengerId);
    isDataLoaded = true;
  }

  /// Replace bus sensor data with CSV content (e.g. from ESP32 log file). Syncs to Supabase.
  ({bool ok, List<String> errors}) setBusSensorDataFromCsv(String raw) {
    final result = CsvDataService.parseBusSensorCsv(raw);
    if (result.errors.isNotEmpty && result.data.isEmpty) {
      return (ok: false, errors: result.errors);
    }
    busSensorData = result.data;
    if (result.data.isNotEmpty) {
      isDataLoaded = true;
      SupabaseService.upsertBusSensorReadings(result.data);
    }
    return (ok: true, errors: result.errors);
  }

  /// Replace passenger health data with CSV content. Syncs to Supabase.
  /// When not admin, only current passenger's rows are kept and synced (passenger cannot see or upload others' data).
  ({bool ok, List<String> errors}) setPassengerHealthDataFromCsv(String raw) {
    final result = CsvDataService.parsePassengerHealthCsv(raw);
    if (result.errors.isNotEmpty && result.data.isEmpty) {
      return (ok: false, errors: result.errors);
    }
    var data = result.data;
    if (!isAdminSession && data.isNotEmpty) {
      data = data.where((r) => r.passengerId == currentPassengerId).toList();
    }
    passengerHealthData = data;
    if (data.isNotEmpty) {
      isDataLoaded = true;
      SupabaseService.upsertPassengerHealthReadings(data);
    }
    return (ok: true, errors: result.errors);
  }

  Future<void> runAiAnalysis() async {
    if (groqApiKey == null || groqApiKey!.trim().isEmpty) {
      throw Exception('Please set your Groq API key first.');
    }
    isAnalyzing = true;
    errorMessage = null;
    try {
      final result = await GroqAiService.analyzePassengers(
        apiKey: groqApiKey!.trim(),
        busSensorData: busSensorData,
        healthData: passengerHealthData,
      );

      final allAssessments = (result['assessments'] as List).map((a) {
        return PassengerAssessment(
          seatNumber: (a['seat'] ?? '').toString(),
          passengerId: (a['passenger_id'] ?? '').toString(),
          passengerName: (a['name'] ?? '').toString(),
          status: (a['status'] ?? 'Normal').toString(),
          reasoning: (a['reasoning'] ?? '').toString(),
      );
    }).toList();

      await SupabaseService.insertPassengerAssessments(allAssessments);
      if (isAdminSession) {
        assessments = allAssessments;
        emergencySummary = result['emergency_summary']?.toString();
        recommendedPriority =
            (result['recommended_priority'] as List?)?.cast<String>();
      } else {
        assessments = allAssessments.where((a) => a.passengerId == currentPassengerId).toList();
        emergencySummary = null;
        recommendedPriority = null;
      }
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isAnalyzing = false;
    }
  }

  // --- Data access helpers ---

  Map<String, List<PassengerHealthReading>> get passengerMap {
    final map = <String, List<PassengerHealthReading>>{};
    for (final r in passengerHealthData) {
      map.putIfAbsent(r.passengerId, () => []).add(r);
    }
    return map;
  }

  List<String> get uniquePassengerIds =>
      passengerHealthData.map((r) => r.passengerId).toSet().toList();

  PassengerHealthReading? latestReading(String passengerId) {
    final list = passengerMap[passengerId];
    return (list != null && list.isNotEmpty) ? list.last : null;
  }

  PassengerHealthReading? baselineReading(String passengerId) {
    final list = passengerMap[passengerId];
    return (list != null && list.isNotEmpty) ? list.first : null;
  }

  PassengerAssessment? assessmentFor(String seatNumber) {
    final idx = assessments.indexWhere((a) => a.seatNumber == seatNumber);
    return idx >= 0 ? assessments[idx] : null;
  }

  bool get hasAccident =>
      busSensorData.any((r) => r.isAccidentEvent);

  BusSensorReading? get peakImpact {
    final hits =
        busSensorData.where((r) => r.eventLabel == 'collision').toList();
    if (hits.isEmpty) return null;
    return hits.reduce(
        (a, b) => a.accelMagnitude > b.accelMagnitude ? a : b);
  }

  int get criticalCount =>
      assessments.where((a) => a.status == 'Critical').length;
  int get panicCount =>
      assessments.where((a) => a.status == 'Panic').length;
  int get normalCount =>
      assessments.where((a) => a.status == 'Normal').length;

  Future<String> askGroq(String question) async {
    if (groqApiKey == null || groqApiKey!.trim().isEmpty) {
      throw Exception('Please set your Groq API key in Setup.');
    }
    return GroqAiService.askAboutPassengers(
      apiKey: groqApiKey!.trim(),
      question: question,
      healthData: passengerHealthData,
      assessments: assessments,
      hasAccident: hasAccident,
      busSensorData: busSensorData,
    );
  }
}
