import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services.dart';
import 'screens.dart';

/// Keys from --dart-define or .env (via run script). Never commit real values.
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  }
  final groqKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  if (groqKey.isNotEmpty) {
    AppState.instance.groqApiKey = groqKey;
  }
  runApp(const SmartBusApp());
}

/// Passenger theme: warm, reassuring (light green/blue tint).
ThemeData get _passengerTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0D9488),
        brightness: Brightness.light,
        primary: const Color(0xFF0D9488),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
    );

/// Admin theme: control-room (dark, high contrast).
ThemeData get _adminTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF34D399),
        surface: Color(0xFF0F172A),
        onSurface: Color(0xFFE2E8F0),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ).apply(bodyColor: const Color(0xFFE2E8F0)),
      cardTheme: CardTheme(
        elevation: 1,
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
    );

class SmartBusApp extends StatefulWidget {
  const SmartBusApp({super.key});

  @override
  State<SmartBusApp> createState() => _SmartBusAppState();
}

class _SmartBusAppState extends State<SmartBusApp> {
  String _currentRoute = '/';

  bool get _isAdminRoute =>
      _currentRoute.startsWith('/admin') || _currentRoute == '/analytics';

  void _handleRouteChanged(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null && name != _currentRoute) {
      setState(() => _currentRoute = name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Bus Emergency Intelligence',
      theme: _isAdminRoute ? _adminTheme : _passengerTheme,
      initialRoute: '/',
      navigatorObservers: [
        _RouteObserver(_handleRouteChanged),
      ],
      onGenerateRoute: (settings) {
        if (settings.name == '/admin-overview' ||
            settings.name == '/admin-charts' ||
            settings.name == '/analytics') {
          if (!AppState.instance.isAdminSession) {
            return MaterialPageRoute(
              builder: (_) => const AdminLoginScreen(),
              settings: settings,
            );
          }
        }
        return null;
      },
      routes: {
        '/': (_) => const LoginScreen(),
        '/setup': (_) => const SetupScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/health-details': (_) => const HealthDetailsScreen(),
        '/emergency': (_) => const EmergencyScreen(),
        '/admin-login': (_) => const AdminLoginScreen(),
        '/admin-overview': (_) => const AdminOverviewScreen(),
        '/admin-charts': (_) => const AdminChartsScreen(),
        '/analytics': (_) => const AnalyticsScreen(),
        '/import': (_) => const ImportDataScreen(),
      },
    );
  }
}

class _RouteObserver extends NavigatorObserver {
  _RouteObserver(this._onRouteChanged);
  final void Function(Route<dynamic>?) _onRouteChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _onRouteChanged(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _onRouteChanged(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _onRouteChanged(newRoute);
  }
}
