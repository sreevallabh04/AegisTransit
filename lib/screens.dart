import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'models.dart';
import 'services.dart';
import 'supabase_service.dart';
import 'widgets.dart';

// ════════════════════════════════════════════════════════════════
//  LOGIN SCREEN
// ════════════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _seatCtrl = TextEditingController(text: 'B12');
  final _idCtrl = TextEditingController(text: 'P-012');
  final _nameCtrl = TextEditingController(text: 'Alex Kumar');
  final _condCtrl = TextEditingController(text: 'No known chronic conditions');
  final _startCtrl = TextEditingController(text: 'City Center Bus Depot');
  final _endCtrl = TextEditingController(text: 'Central Hospital');

  @override
  void dispose() {
    _seatCtrl.dispose();
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _condCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  void _proceed() {
    final state = AppState.instance;
    state.currentSeat = _seatCtrl.text.trim();
    state.currentPassengerId = _idCtrl.text.trim();
    state.currentPassengerName = _nameCtrl.text.trim();
    Navigator.pushReplacementNamed(context, '/setup');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F2F1),
              Color(0xFFB2DFDB),
              Color(0xFF80CBC4),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Icon(Icons.directions_bus_rounded,
                          size: 56, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text('You\'re in safe hands',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF004D40),
                          ),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('Smart Bus — Passenger check-in',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF00695C),
                          ),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 28),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Your details',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF004D40),
                                  )),
                              const SizedBox(height: 16),
                              _field(_seatCtrl, 'Seat Number', Icons.event_seat),
                              _field(_idCtrl, 'Passenger ID', Icons.badge),
                              _field(_nameCtrl, 'Full Name', Icons.person),
                              const SizedBox(height: 16),
                              Text('Health & trip',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF004D40),
                                  )),
                              const SizedBox(height: 12),
                              _field(_condCtrl, 'Existing health conditions',
                                  Icons.health_and_safety, maxLines: 2),
                              _field(_startCtrl, 'From', Icons.place),
                              _field(_endCtrl, 'To', Icons.local_hospital),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _proceed,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Continue',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/admin-login'),
                          child: Text('Are you an admin? Log in here',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF00695C),
                                decoration: TextDecoration.underline,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  SETUP SCREEN – loads CSV data and accepts Groq API key
// ════════════════════════════════════════════════════════════════

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _loading = true;
  String? _error;
  final _apiKeyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await AppState.instance.loadData();
    } catch (_) {
      _error = 'Could not load data. Check connection or use CSV import.';
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showConnectEsp32Sheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _ConnectEsp32Sheet(
          onClosed: () => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'System Setup',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SeatIdentityHeader(
                  seatNumber: state.currentSeat,
                  passengerId: state.currentPassengerId,
                  subtitle: 'CSV sensor data loaded from assets.',
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data Status',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (_error != null)
                          Text('Error: $_error',
                              style: const TextStyle(color: Colors.red)),
                        if (_error == null) ...[
                          Text(
                              'Bus sensor readings: ${state.busSensorData.length}'),
                          Text(
                              state.isAdminSession
                                  ? 'Passenger health readings: ${state.passengerHealthData.length}'
                                  : 'Your health readings: ${state.passengerHealthData.length}'),
                          if (state.isAdminSession)
                            Text(
                                'Unique passengers: ${state.uniquePassengerIds.length}'),
                          Text(
                              'Accident detected: ${state.hasAccident ? "YES" : "No"}'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data source',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        FilledButton.tonalIcon(
                          onPressed: () => Navigator.pushNamed(context, '/import'),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Import CSV files (ESP32 + Passenger)'),
                        ),
                        const SizedBox(height: 8),
                        Text('Bus sensor (ESP32)',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        const Text(
                          'Connect to the bus ESP32 (MPU6050 + alcohol sensor on D15) to stream live sensor data via BLE. Upload the Arduino sketch from arduino/esp32_bus_sensors and set ENABLE_BLE=1, ALCOHOL_PIN=34.',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _showConnectEsp32Sheet(context),
                          icon: const Icon(Icons.bluetooth_searching),
                          label: const Text('Connect to ESP32 sensor'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Groq API Key',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        const Text(
                          'Enter your Groq API key for AI-powered passenger assessment and admin Q&A. '
                          'Get one free at console.groq.com',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _apiKeyCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'API Key',
                            prefixIcon: Icon(Icons.key),
                            border: OutlineInputBorder(),
                            hintText: 'gsk_...',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _error != null
                      ? null
                      : () {
                          state.groqApiKey =
                              _apiKeyCtrl.text.trim().isEmpty
                                  ? null
                                  : _apiKeyCtrl.text.trim();
                          Navigator.pushReplacementNamed(
                              context, '/dashboard');
                        },
                  icon: const Icon(Icons.dashboard),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Continue to Dashboard',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  CONNECT TO ESP32 BLE BUS SENSOR
// ════════════════════════════════════════════════════════════════

class _ConnectEsp32Sheet extends StatefulWidget {
  const _ConnectEsp32Sheet({required this.onClosed});

  final VoidCallback onClosed;

  @override
  State<_ConnectEsp32Sheet> createState() => _ConnectEsp32SheetState();
}

class _ConnectEsp32SheetState extends State<_ConnectEsp32Sheet> {
  String _status = 'Turn on Bluetooth and tap Scan.';
  int _liveCount = 0;
  bool _scanning = false;
  bool _connected = false;
  StreamSubscription<List<int>>? _sub;
  BluetoothDevice? _device;

  static const _serviceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const _charUuid = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const _deviceName = 'SmartBusESP32';

  @override
  void dispose() {
    _sub?.cancel();
    _device?.disconnect();
    super.dispose();
  }

  Future<void> _scanAndConnect() async {
    if (_scanning || _connected) return;
    setState(() {
      _scanning = true;
      _status = 'Scanning for $_deviceName...';
    });
    try {
      if (!await FlutterBluePlus.isSupported) {
        setState(() {
          _status = 'BLE not supported on this device.';
          _scanning = false;
        });
        return;
      }
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        await FlutterBluePlus.turnOn();
      }
      BluetoothDevice? found;
      final serviceGuid = Guid(_serviceUuid);
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        withNames: [_deviceName],
        withServices: [serviceGuid],
      );
      final results = FlutterBluePlus.lastScanResults;
      await FlutterBluePlus.stopScan();
      for (final res in results) {
        if (res.device.platformName == _deviceName ||
            res.advertisementData.serviceUuids.any((u) =>
                u.toString().toLowerCase() == _serviceUuid.toLowerCase())) {
          found = res.device;
          break;
        }
      }
      if (found == null && results.isNotEmpty) {
        found = results.first.device;
      }
      if (!mounted) return;
      if (found == null) {
        setState(() {
          _status = 'ESP32 not found. Ensure sketch has ENABLE_BLE=1 and device is near.';
          _scanning = false;
        });
        return;
      }
      _device = found;
      final device = found;
      setState(() {
        _status = 'Connecting to ${device.platformName.isNotEmpty ? device.platformName : device.remoteId}...';
      });
      await device.connect();
      if (!mounted) return;
      setState(() {
        _connected = true;
        _scanning = false;
        _status = 'Discovering services...';
      });
      final services = await device.discoverServices();
      BluetoothCharacteristic? char;
      for (final svc in services) {
        if (svc.uuid.toString().toLowerCase() == _serviceUuid.toLowerCase()) {
          for (final c in svc.characteristics) {
            if (c.uuid.toString().toLowerCase() == _charUuid.toLowerCase()) {
              char = c;
              break;
            }
          }
          break;
        }
      }
      if (char == null || !mounted) {
        setState(() {
          _status = 'Sensor characteristic not found.';
          _connected = false;
        });
        return;
      }
      await char.setNotifyValue(true);
      setState(() => _status = 'Receiving live sensor data. Readings appear below.');
      _sub = char.lastValueStream.listen((List<int> value) {
        final line = utf8.decode(value);
        final reading = CsvDataService.parseBusSensorLine(line);
        if (reading != null) {
          AppState.instance.busSensorData.add(reading);
          if (mounted) {
            setState(() => _liveCount = AppState.instance.busSensorData.length);
          }
          widget.onClosed();
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _status = 'Connection failed. Ensure Bluetooth is on and device is paired.';
          _scanning = false;
          _connected = false;
        });
      }
    }
  }

  Future<void> _disconnect() async {
    await _sub?.cancel();
    _sub = null;
    await _device?.disconnect();
    _device = null;
    if (mounted) {
      setState(() {
        _connected = false;
        _status = 'Disconnected.';
      });
      widget.onClosed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Connect to bus sensor (ESP32)', style: theme.textTheme.titleMedium),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_status, style: theme.textTheme.bodyMedium),
          if (_liveCount > 0) Text('Live readings: $_liveCount', style: theme.textTheme.titleSmall),
          const SizedBox(height: 16),
          if (!_connected)
            FilledButton.icon(
              onPressed: _scanning ? null : _scanAndConnect,
              icon: _scanning ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.bluetooth_searching),
              label: Text(_scanning ? 'Scanning...' : 'Scan & connect'),
            )
          else
            OutlinedButton.icon(
              onPressed: _disconnect,
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Disconnect'),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  IMPORT DATA – production CSV import (ESP32 + Passenger)
// ════════════════════════════════════════════════════════════════

class ImportDataScreen extends StatefulWidget {
  const ImportDataScreen({super.key});

  @override
  State<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends State<ImportDataScreen> {
  String _busCsvRaw = '';
  String _passengerCsvRaw = '';
  List<String> _busErrors = [];
  List<String> _passengerErrors = [];
  List<BusSensorReading> _busPreview = [];
  List<PassengerHealthReading> _passengerPreview = [];
  bool _busApplied = false;
  bool _passengerApplied = false;
  final _busCsvCtrl = TextEditingController();
  final _passengerCsvCtrl = TextEditingController();

  @override
  void dispose() {
    _busCsvCtrl.dispose();
    _passengerCsvCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isBus) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.single.bytes;
    if (bytes == null) return;
    final text = utf8.decode(bytes);
    if (isBus) {
      _busCsvCtrl.text = text;
      setState(() {
        _busCsvRaw = text;
        final res = CsvDataService.parseBusSensorCsv(text);
        _busPreview = res.data.take(5).toList();
        _busErrors = res.errors;
        _busApplied = false;
      });
    } else {
      _passengerCsvCtrl.text = text;
      setState(() {
        _passengerCsvRaw = text;
        final res = CsvDataService.parsePassengerHealthCsv(text);
        _passengerPreview = res.data.take(5).toList();
        _passengerErrors = res.errors;
        _passengerApplied = false;
      });
    }
  }

  void _applyBus() {
    if (_busCsvRaw.trim().isEmpty) return;
    final res = AppState.instance.setBusSensorDataFromCsv(_busCsvRaw);
    if (res.ok) {
      setState(() => _busApplied = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Bus data loaded: ${AppState.instance.busSensorData.length} rows'),
        backgroundColor: AppColors.normal,
      ));
      if (res.errors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Warnings: ${res.errors.length} row(s) skipped'),
          backgroundColor: Colors.orange,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${res.errors.join("; ")}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _applyPassenger() {
    if (_passengerCsvRaw.trim().isEmpty) return;
    final res = AppState.instance.setPassengerHealthDataFromCsv(_passengerCsvRaw);
    if (res.ok) {
      setState(() => _passengerApplied = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Passenger data loaded: ${AppState.instance.passengerHealthData.length} rows'),
        backgroundColor: AppColors.normal,
      ));
      if (res.errors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Warnings: ${res.errors.length} row(s) skipped'),
          backgroundColor: Colors.orange,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${res.errors.join("; ")}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _loadDemoData() async {
    await AppState.instance.loadData();
    setState(() {
      _busApplied = true;
      _passengerApplied = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Demo data (assets) loaded'),
        backgroundColor: AppColors.normal,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Import CSV Data',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Load bus sensor (ESP32) and passenger health CSVs for the demo. Two file types supported.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              csvController: _busCsvCtrl,
              title: '1. Bus / ESP32 sensor CSV',
              subtitle: 'From Arduino Serial log or exported file. Columns: timestamp, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z, alcohol_ppm, sos_triggered, speed_kmh, event_label',
              csvRaw: _busCsvRaw,
              onCsvChanged: (v) {
                setState(() {
                  _busCsvRaw = v;
                  final res = CsvDataService.parseBusSensorCsv(v);
                  _busPreview = res.data.take(5).toList();
                  _busErrors = res.errors;
                  _busApplied = false;
                });
              },
              errors: _busErrors,
              previewRows: _busPreview.length,
              preview: _busPreview.isEmpty
                  ? null
                  : Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          children: [
                            _cell(theme, 'Time', true),
                            _cell(theme, 'Accel (m/s²)', true),
                            _cell(theme, 'Event', true),
                          ],
                        ),
                        ..._busPreview.map((r) => TableRow(
                          children: [
                            _cell(theme, '${r.timestamp.hour}:${r.timestamp.minute.toString().padLeft(2, '0')}', false),
                            _cell(theme, r.accelMagnitude.toStringAsFixed(2), false),
                            _cell(theme, r.eventLabel, false),
                          ],
                        )),
                      ],
                    ),
              applied: _busApplied,
              onPickFile: () => _pickFile(true),
              onApply: _applyBus,
            ),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              csvController: _passengerCsvCtrl,
              title: '2. Passenger health CSV',
              subtitle: 'Heart rate, HRV, SpO2, etc. per passenger. Columns: timestamp, seat_number, passenger_id, passenger_name, heart_rate_bpm, hrv_ms, motion_intensity, skin_temp_c, spo2_percent, existing_condition, start_dest, end_dest',
              csvRaw: _passengerCsvRaw,
              onCsvChanged: (v) {
                setState(() {
                  _passengerCsvRaw = v;
                  final res = CsvDataService.parsePassengerHealthCsv(v);
                  _passengerPreview = res.data.take(5).toList();
                  _passengerErrors = res.errors;
                  _passengerApplied = false;
                });
              },
              errors: _passengerErrors,
              previewRows: _passengerPreview.length,
              preview: _passengerPreview.isEmpty
                  ? null
                  : Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          children: [
                            _cell(theme, 'Seat', true),
                            _cell(theme, 'Name', true),
                            _cell(theme, 'HR', true),
                          ],
                        ),
                        ..._passengerPreview.map((r) => TableRow(
                          children: [
                            _cell(theme, r.seatNumber, false),
                            _cell(theme, r.passengerName, false),
                            _cell(theme, '${r.heartRateBpm}', false),
                          ],
                        )),
                      ],
                    ),
              applied: _passengerApplied,
              onPickFile: () => _pickFile(false),
              onApply: _applyPassenger,
            ),
            const SizedBox(height: 24),
            const Divider(),
            OutlinedButton.icon(
              onPressed: _loadDemoData,
              icon: const Icon(Icons.folder_open),
              label: const Text('Use demo data from app assets'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
              icon: const Icon(Icons.dashboard),
              label: const Text('Continue to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme, {
    required TextEditingController csvController,
    required String title,
    required String subtitle,
    required String csvRaw,
    required ValueChanged<String> onCsvChanged,
    required List<String> errors,
    required int previewRows,
    required Widget? preview,
    required bool applied,
    required VoidCallback onPickFile,
    required VoidCallback onApply,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (applied) Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Chip(label: const Text('Applied'), backgroundColor: Colors.green.shade100),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.tonalIcon(onPressed: onPickFile, icon: const Icon(Icons.upload_file), label: const Text('Pick file')),
                const SizedBox(width: 8),
                if (csvRaw.isNotEmpty)
                  Text('${csvRaw.split('\n').length} lines', style: theme.textTheme.bodySmall),
              ],
            ),
            if (csvRaw.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: TextField(
                  maxLines: null,
                  controller: csvController,
                  onChanged: onCsvChanged,
                  decoration: const InputDecoration(
                    labelText: 'Or paste CSV here',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              if (errors.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Warnings: ${errors.take(3).join(" ")}', style: TextStyle(color: Colors.orange.shade800, fontSize: 12)),
                ),
              if (preview != null) ...[
                const SizedBox(height: 8),
                Text('Preview (first $previewRows rows)', style: theme.textTheme.labelMedium),
                const SizedBox(height: 4),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: preview),
              ],
              const SizedBox(height: 8),
              FilledButton(onPressed: onApply, child: const Text('Use this data in app')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cell(ThemeData theme, String text, bool header) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(text, style: header ? theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600) : theme.textTheme.bodySmall),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  DASHBOARD
// ════════════════════════════════════════════════════════════════

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _analyzing = false;
  List<AppNotification>? _notifications;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await SupabaseService.fetchNotificationsForPassenger(
        AppState.instance.currentPassengerId);
    if (mounted) setState(() => _notifications = list);
  }

  static String _formatNotifTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _runAi() async {
    final state = AppState.instance;
    if (state.groqApiKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('No API key set. Go back to Setup to enter your key.')));
      return;
    }
    setState(() => _analyzing = true);
    try {
      await state.runAiAnalysis();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('AI analysis complete!'),
            backgroundColor: AppColors.normal));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Analysis failed. Check your connection and API key.'),
                backgroundColor: Colors.red));
      }
    }
    if (mounted) setState(() => _analyzing = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final latest = state.latestReading(state.currentPassengerId);
    final assessment = state.assessmentFor(state.currentSeat);

    final healthStatus = assessment?.status ?? 'Awaiting AI';
    final healthColor = assessment != null
        ? AppColors.statusColor(assessment.status)
        : Colors.grey;

    final busStatus = state.hasAccident ? 'ACCIDENT DETECTED' : 'Normal';
    final busColor = state.hasAccident ? AppColors.accident : AppColors.normal;

    return AppScaffold(
      title: 'Dashboard',
      actions: [
        if (state.hasAccident)
          IconButton(
            tooltip: 'Emergency Alert',
            onPressed: () => Navigator.pushNamed(context, '/emergency'),
            icon: const Icon(Icons.warning_rounded, color: AppColors.critical),
          ),
      ],
      child: ListView(
        children: [
          SeatIdentityHeader(
            seatNumber: state.currentSeat,
            passengerId: state.currentPassengerId,
            subtitle: latest != null
                ? 'HR: ${latest.heartRateBpm} bpm  •  SpO2: ${latest.spo2Percent}%'
                : null,
          ),
          if (_notifications != null) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My notifications',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_notifications!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No notifications yet.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      )
                    else ...[
                      if (_notifications!.any((n) => n.isUnread))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Text(
                                  '${_notifications!.where((n) => n.isUnread).length} unread',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ..._notifications!.take(5).map((n) => ListTile(
                            dense: true,
                            leading: Icon(
                              n.isUnread ? Icons.mark_email_unread : Icons.done_all,
                              color: n.isUnread ? Theme.of(context).colorScheme.primary : Colors.grey,
                            ),
                            title: Text(n.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: n.isUnread ? FontWeight.w600 : FontWeight.normal,
                                )),
                            subtitle: Text(
                              _formatNotifTime(n.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onTap: () async {
                              if (n.isUnread) {
                                await SupabaseService.markNotificationRead(n.id);
                                _loadNotifications();
                              }
                            },
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          StatusCard(
            title: 'Bus Status',
            value: busStatus,
            color: busColor,
            icon: Icons.directions_bus,
            helperText: state.hasAccident
                ? 'Peak impact: ${state.peakImpact?.accelMagnitude.toStringAsFixed(1)} m/s²'
                : 'All systems normal.',
          ),
          const SizedBox(height: 12),
          StatusCard(
            title: 'Health Status',
            value: healthStatus,
            color: healthColor,
            icon: Icons.favorite,
            helperText: assessment?.reasoning,
          ),
          const SizedBox(height: 12),
          if (state.isAdminSession && state.assessments.isNotEmpty) ...[
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Emergency Summary',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(state.emergencySummary ?? 'No summary available.'),
                    if (state.recommendedPriority != null) ...[
                      const SizedBox(height: 8),
                      Text(
                          'Priority order: ${state.recommendedPriority!.join(" → ")}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Actions',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _analyzing ? null : _runAi,
                    icon: _analyzing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                          _analyzing
                              ? 'Analyzing with Groq AI...'
                              : 'Run AI Passenger Analysis',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/health-details'),
                    icon: const Icon(Icons.monitor_heart),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('View Health Details',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/analytics'),
                    icon: const Icon(Icons.analytics),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('View Analytics',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (state.hasAccident)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accident,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/emergency'),
                      icon: const Icon(Icons.sos),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('View Emergency Alert',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  HEALTH DETAILS with line charts
// ════════════════════════════════════════════════════════════════

class HealthDetailsScreen extends StatelessWidget {
  const HealthDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final readings =
        state.passengerMap[state.currentPassengerId] ?? [];
    final latest = readings.isNotEmpty ? readings.last : null;
    final baseline = readings.isNotEmpty ? readings.first : null;
    final assessment = state.assessmentFor(state.currentSeat);

    return AppScaffold(
      title: 'Health Details',
      child: ListView(
        children: [
          SeatIdentityHeader(
            seatNumber: state.currentSeat,
            passengerId: state.currentPassengerId,
            subtitle: 'Real-time metrics from CSV sensor data.',
          ),
          const SizedBox(height: 12),
          if (assessment != null)
            Card(
              elevation: 1,
              color: AppColors.statusColor(assessment.status).withAlpha(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    HealthBadge(
                        label: assessment.status,
                        color:
                            AppColors.statusColor(assessment.status)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(assessment.reasoning,
                            style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            ),
          if (assessment != null) const SizedBox(height: 12),
          MetricCard(
            title: 'Heart Rate',
            value: latest != null ? '${latest.heartRateBpm} bpm' : '--',
            icon: Icons.favorite_rounded,
            accentColor: AppColors.critical,
            description: baseline != null
                ? 'Baseline: ${baseline.heartRateBpm} bpm'
                : null,
            child: readings.length > 1
                ? SizedBox(
                    height: 150,
                    child: _buildLineChart(
                      readings,
                      (r) => r.heartRateBpm.toDouble(),
                      AppColors.critical,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          MetricCard(
            title: 'Heart Rate Variability',
            value: latest != null ? '${latest.hrvMs} ms' : '--',
            icon: Icons.timeline_rounded,
            accentColor: AppColors.brandSeed,
            description:
                baseline != null ? 'Baseline: ${baseline.hrvMs} ms' : null,
            child: readings.length > 1
                ? SizedBox(
                    height: 150,
                    child: _buildLineChart(
                      readings,
                      (r) => r.hrvMs,
                      AppColors.brandSeed,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          MetricCard(
            title: 'SpO2',
            value: latest != null ? '${latest.spo2Percent}%' : '--',
            icon: Icons.air_rounded,
            accentColor: AppColors.normal,
            description: 'Blood oxygen saturation level.',
          ),
          const SizedBox(height: 12),
          MetricCard(
            title: 'Motion Intensity',
            value: latest != null
                ? latest.motionIntensity.toStringAsFixed(2)
                : '--',
            icon: Icons.directions_walk_rounded,
            accentColor: AppColors.panic,
            description: baseline != null
                ? 'Baseline: ${baseline.motionIntensity}'
                : null,
          ),
          const SizedBox(height: 12),
          MetricCard(
            title: 'Skin Temperature',
            value: latest != null ? '${latest.skinTempC} °C' : '--',
            icon: Icons.thermostat_rounded,
            accentColor: Colors.deepOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(
    List<PassengerHealthReading> readings,
    double Function(PassengerHealthReading) getValue,
    Color color,
  ) {
    final first = readings.first.timestamp;
    final spots = readings.map((r) {
      final min = r.timestamp.difference(first).inSeconds / 60.0;
      return FlSpot(min, getValue(r));
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (v, _) =>
                  Text('${v.toInt()}m', style: const TextStyle(fontSize: 10)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) =>
                  Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withAlpha(40),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  EMERGENCY ALERT
// ════════════════════════════════════════════════════════════════

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final peak = state.peakImpact;

    return Scaffold(
      backgroundColor: AppColors.accident,
      appBar: AppBar(
        backgroundColor: AppColors.accident,
        foregroundColor: Colors.white,
        title: const Text('Emergency Alert'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: AppColors.accident, size: 32),
                          SizedBox(width: 8),
                          Text('COLLISION DETECTED',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.accident)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (peak != null) ...[
                        Text(
                            'Time: ${peak.timestamp.toString().substring(0, 19)}'),
                        Text(
                            'Impact force: ${peak.accelMagnitude.toStringAsFixed(1)} m/s²'),
                        Text(
                            'Gyroscope: ${peak.gyroMagnitude.toStringAsFixed(1)} °/s'),
                      ],
                      if (state.isAdminSession)
                        Text(
                            'Total passengers: ${state.uniquePassengerIds.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (state.assessments.isNotEmpty) ...[
                Expanded(
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              state.isAdminSession
                                  ? 'Passenger Severity Report'
                                  : 'Your status',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          if (state.isAdminSession &&
                              state.emergencySummary != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(state.emergencySummary!,
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: state.assessments.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final a = state.assessments[i];
                                return ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.statusColor(a.status),
                                    radius: 16,
                                    child: Text(a.seatNumber,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                  title: Text(
                                      '${a.passengerName} — ${a.status}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.statusColor(
                                              a.status))),
                                  subtitle: Text(a.reasoning,
                                      style: const TextStyle(fontSize: 12)),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else
                const Expanded(
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 72, color: AppColors.accident),
                          SizedBox(height: 12),
                          Text('ACCIDENT DETECTED',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.accident)),
                          SizedBox(height: 10),
                          Text(
                            'Run AI Analysis from the Dashboard to generate passenger severity reports.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.accident,
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Back to Dashboard',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  ADMIN LOGIN
// ════════════════════════════════════════════════════════════════

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        color: const Color(0xFF0F172A),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('FLEET CONTROL',
                        style: theme.textTheme.titleLarge?.copyWith(
                          letterSpacing: 4,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF34D399),
                        ),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text('Admin console',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    Card(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                            color: Color(0xFF334155), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('ADMIN ID',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  letterSpacing: 1,
                                )),
                            const SizedBox(height: 8),
                            const TextField(
                              style: TextStyle(color: Color(0xFFE2E8F0)),
                              decoration: InputDecoration(
                                hintText: 'admin',
                                prefixIcon: Icon(Icons.badge_outlined,
                                    color: Color(0xFF64748B)),
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text('PASSWORD',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  letterSpacing: 1,
                                )),
                            const SizedBox(height: 8),
                            const TextField(
                              obscureText: true,
                              style: TextStyle(color: Color(0xFFE2E8F0)),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: Color(0xFF64748B)),
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () async {
                                AppState.instance.isAdminSession = true;
                                if (!AppState.instance.isDataLoaded) {
                                  await AppState.instance.loadData();
                                }
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(
                                      context, '/admin-overview');
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF34D399),
                                foregroundColor: const Color(0xFF0F172A),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.directions_bus_filled),
                              label: const Text('VIEW BUS OVERVIEW',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2)),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Back to passenger login',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF94A3B8),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  ADMIN BUS OVERVIEW – all passengers, real data + Groq Q&A
// ════════════════════════════════════════════════════════════════

class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});

  static void _showAskGroqSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => const _AdminAskGroqSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final ids = state.uniquePassengerIds;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Seat Overview'),
        actions: [
          IconButton(
            tooltip: 'Passenger sensor charts',
            onPressed: () => Navigator.pushNamed(context, '/admin-charts'),
            icon: const Icon(Icons.show_chart),
          ),
          IconButton(
            tooltip: 'Ask about passengers (Groq)',
            onPressed: () => _showAskGroqSheet(context),
            icon: const Icon(Icons.psychology_alt),
          ),
          IconButton(
            tooltip: 'Back to Login',
            onPressed: () {
              AppState.instance.isAdminSession = false;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/', (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Seat-wise Passenger Health (Live CSV Data)',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                  '${ids.length} passengers • ${state.assessments.length} AI assessments',
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Expanded(
                child: ids.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No passenger data for this trip.',
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Load CSV or connect a device from the passenger Setup screen.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : LayoutBuilder(builder: (context, constraints) {
                        final cols = constraints.maxWidth < 520 ? 1 : 2;
                        final ratio = cols == 1 ? 2.0 : 1.2;
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: ratio,
                          ),
                          itemCount: ids.length,
                          itemBuilder: (_, i) {
                            final latest = state.latestReading(ids[i])!;
                      final assessment =
                          state.assessmentFor(latest.seatNumber);
                      final status =
                          assessment?.status ?? 'Pending';
                      final color = assessment != null
                          ? AppColors.statusColor(assessment.status)
                          : Colors.grey;
                      return Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Seat ${latest.seatNumber}',
                                            style:
                                                theme.textTheme.titleMedium),
                                        Text(
                                            '${latest.passengerName} • ${latest.passengerId}',
                                            style: theme.textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  HealthBadge(
                                      label: status, color: color),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  MetricChip(
                                      icon: Icons.favorite_rounded,
                                      label: '${latest.heartRateBpm} bpm'),
                                  MetricChip(
                                      icon: Icons.psychology_alt_rounded,
                                      label: 'HRV ${latest.hrvMs}'),
                                  MetricChip(
                                      icon: Icons.air_rounded,
                                      label: 'SpO2 ${latest.spo2Percent}%'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Condition: ${latest.existingCondition}',
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              if (assessment != null) ...[
                                const SizedBox(height: 4),
                                Text('AI: ${assessment.reasoning}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: color,
                                        fontStyle: FontStyle.italic),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                              const Spacer(),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showNotifyDialog(
                                    context,
                                    passengerId: latest.passengerId,
                                    seatNumber: latest.seatNumber,
                                    name: latest.passengerName,
                                  ),
                                  icon: const Icon(Icons.notifications_active, size: 18),
                                  label: const Text('Notify'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showNotifyDialog(
    BuildContext context, {
    required String passengerId,
    required String seatNumber,
    required String name,
  }) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Notify $name (Seat $seatNumber)'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Message to passenger...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final msg = controller.text.trim();
              if (msg.isEmpty) return;
              await SupabaseService.sendNotification(
                passengerId: passengerId,
                seatNumber: seatNumber,
                message: msg,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Notification sent')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet: Admin can ask "How is person A?", "How is Riya?", etc. Groq answers based on passenger data.
class _AdminAskGroqSheet extends StatefulWidget {
  const _AdminAskGroqSheet();

  @override
  State<_AdminAskGroqSheet> createState() => _AdminAskGroqSheetState();
}

class _AdminAskGroqSheetState extends State<_AdminAskGroqSheet> {
  final _questionCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  String? _response;
  bool _asking = false;
  String? _error;

  @override
  void dispose() {
    _questionCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final q = _questionCtrl.text.trim();
    if (q.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a question (e.g. How is person A?)')),
      );
      return;
    }
    final state = AppState.instance;
    if (state.groqApiKey == null || state.groqApiKey!.trim().isEmpty) {
      final key = _apiKeyCtrl.text.trim();
      if (key.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter Groq API key first')),
        );
        return;
      }
      state.groqApiKey = key;
    }
    setState(() {
      _asking = true;
      _response = null;
      _error = null;
    });
    try {
      final answer = await state.askGroq(q);
      if (mounted) {
        setState(() {
          _response = answer;
          _asking = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Request failed. Check connection and API key.';
          _asking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final theme = Theme.of(context);
    final needsKey = state.groqApiKey == null || state.groqApiKey!.trim().isEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ask about passengers (Groq)',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Ask questions like: "How is person A?", "How is Riya?", "Who needs the most urgent attention?"',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (needsKey) ...[
              TextField(
                controller: _apiKeyCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Groq API Key',
                  hintText: 'gsk_...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _questionCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'e.g. How is person A? How is Riya? Who is critical?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _asking ? null : _ask,
              icon: _asking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(_asking ? 'Asking Groq...' : 'Ask Groq'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              ),
            if (_response != null) ...[
              Text('Response', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_response!, style: theme.textTheme.bodyMedium),
                    ),
                  ),
                ),
              ),
            ] else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  ADMIN CHARTS – passenger sensor readings (HR, SpO2, HRV, motion)
// ════════════════════════════════════════════════════════════════

class AdminChartsScreen extends StatelessWidget {
  const AdminChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger sensor charts'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text('Heart rate, SpO2, HRV, motion by passenger',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: _HeartRateComparisonChart(passengerMap: state.passengerMap),
              ),
              const SizedBox(height: 24),
              if (state.busSensorData.isNotEmpty) ...[
                Text('Bus acceleration', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(height: 200, child: _AccelChart(data: state.busSensorData)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  ANALYTICS SCREEN – charts & statistics
// ════════════════════════════════════════════════════════════════

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Analytics',
      child: ListView(
        children: [
          // ── Summary stats row ──
          Row(
            children: [
              Expanded(
                child: SummaryStatCard(
                  label: 'Sensor\nReadings',
                  value: '${state.busSensorData.length}',
                  color: AppColors.brandSeed,
                  icon: Icons.sensors,
                ),
              ),
              Expanded(
                child: SummaryStatCard(
                  label: 'Health\nReadings',
                  value: '${state.passengerHealthData.length}',
                  color: Colors.teal,
                  icon: Icons.monitor_heart,
                ),
              ),
              Expanded(
                child: SummaryStatCard(
                  label: 'Peak\nImpact',
                  value:
                      state.peakImpact?.accelMagnitude.toStringAsFixed(1) ?? '—',
                  color: AppColors.critical,
                  icon: Icons.flash_on,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Bus Acceleration Timeline ──
          Text('Bus Acceleration Timeline',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Acceleration magnitude (m/s²) over time — collision spike visible.',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          SizedBox(height: 220, child: _AccelChart(data: state.busSensorData)),
          const SizedBox(height: 24),

          // ── Heart Rate Comparison ──
          Text('Heart Rate Comparison (All Passengers)',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('BPM trends across all 6 passengers before, during, and after accident.',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: _HeartRateComparisonChart(passengerMap: state.passengerMap),
          ),
          const SizedBox(height: 8),
          _buildLegend(state.passengerMap),
          const SizedBox(height: 24),

          // ── Severity Distribution ──
          if (state.assessments.isNotEmpty) ...[
            Text('AI Severity Distribution',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SummaryStatCard(
                    label: 'Normal',
                    value: '${state.normalCount}',
                    color: AppColors.normal,
                    icon: Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: SummaryStatCard(
                    label: 'Panic',
                    value: '${state.panicCount}',
                    color: AppColors.panic,
                    icon: Icons.psychology_alt,
                  ),
                ),
                Expanded(
                  child: SummaryStatCard(
                    label: 'Critical',
                    value: '${state.criticalCount}',
                    color: AppColors.critical,
                    icon: Icons.dangerous,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: _SeverityPieChart(
                normal: state.normalCount,
                panic: state.panicCount,
                critical: state.criticalCount,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Speed Timeline ──
          Text('Bus Speed Timeline', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(height: 180, child: _SpeedChart(data: state.busSensorData)),
          const SizedBox(height: 24),

          // ── Per-passenger cards ──
          if (state.assessments.isNotEmpty) ...[
            Text('Per-Passenger AI Assessment',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...state.assessments.map((a) => Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.statusColor(a.status),
                      child: Text(a.seatNumber,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                    title: Text('${a.passengerName} — ${a.status}',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.statusColor(a.status))),
                    subtitle: Text(a.reasoning),
                  ),
                )),
          ],
          if (state.assessments.isEmpty)
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const Text(
                      'Run AI Analysis from the Dashboard to see severity distribution and per-passenger assessments.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLegend(Map<String, List<PassengerHealthReading>> map) {
    final ids = map.keys.toList();
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: List.generate(ids.length, (i) {
        final name = map[ids[i]]!.first.passengerName;
        final color =
            AppColors.chartPalette[i % AppColors.chartPalette.length];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, color: color),
            const SizedBox(width: 4),
            Text(name, style: const TextStyle(fontSize: 11)),
          ],
        );
      }),
    );
  }
}

// ── Acceleration magnitude line chart ──
class _AccelChart extends StatelessWidget {
  const _AccelChart({required this.data});
  final List<BusSensorReading> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final first = data.first.timestamp;
    final spots = data.map((r) {
      final sec = r.timestamp.difference(first).inSeconds / 60.0;
      return FlSpot(sec, r.accelMagnitude);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (v, _) =>
                  Text('${v.toInt()}m', style: const TextStyle(fontSize: 10)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) =>
                  Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.critical,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.critical.withAlpha(40),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Heart rate multi-line chart ──
class _HeartRateComparisonChart extends StatelessWidget {
  const _HeartRateComparisonChart({required this.passengerMap});
  final Map<String, List<PassengerHealthReading>> passengerMap;

  @override
  Widget build(BuildContext context) {
    final ids = passengerMap.keys.toList();
    if (ids.isEmpty) return const SizedBox.shrink();

    final allReadings = passengerMap.values.expand((e) => e).toList();
    final firstTime = allReadings
        .map((r) => r.timestamp)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final bars = <LineChartBarData>[];
    for (var i = 0; i < ids.length; i++) {
      final readings = passengerMap[ids[i]]!;
      final color =
          AppColors.chartPalette[i % AppColors.chartPalette.length];
      bars.add(LineChartBarData(
        spots: readings.map((r) {
          final min = r.timestamp.difference(firstTime).inSeconds / 60.0;
          return FlSpot(min, r.heartRateBpm.toDouble());
        }).toList(),
        isCurved: true,
        color: color,
        barWidth: 2,
        dotData: const FlDotData(show: false),
      ));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (v, _) =>
                  Text('${v.toInt()}m', style: const TextStyle(fontSize: 10)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) =>
                  Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: bars,
      ),
    );
  }
}

// ── Severity pie chart ──
class _SeverityPieChart extends StatelessWidget {
  const _SeverityPieChart({
    required this.normal,
    required this.panic,
    required this.critical,
  });
  final int normal, panic, critical;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        centerSpaceRadius: 40,
        sectionsSpace: 3,
        sections: [
          if (normal > 0)
            PieChartSectionData(
              value: normal.toDouble(),
              title: 'Normal\n$normal',
              color: AppColors.normal,
              radius: 70,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          if (panic > 0)
            PieChartSectionData(
              value: panic.toDouble(),
              title: 'Panic\n$panic',
              color: AppColors.panic,
              radius: 70,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          if (critical > 0)
            PieChartSectionData(
              value: critical.toDouble(),
              title: 'Critical\n$critical',
              color: AppColors.critical,
              radius: 70,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
        ],
      ),
    );
  }
}

// ── Speed timeline chart ──
class _SpeedChart extends StatelessWidget {
  const _SpeedChart({required this.data});
  final List<BusSensorReading> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final first = data.first.timestamp;
    final spots = data.map((r) {
      final min = r.timestamp.difference(first).inSeconds / 60.0;
      return FlSpot(min, r.speedKmh);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (v, _) =>
                  Text('${v.toInt()}m', style: const TextStyle(fontSize: 10)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) =>
                  Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.brandSeed,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.brandSeed.withAlpha(40),
            ),
          ),
        ],
      ),
    );
  }
}
