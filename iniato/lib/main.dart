import 'package:flutter/material.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/signup_page.dart';
import 'screens/auth/role_selection_page.dart';
import 'screens/home/passenger_dashboard.dart';
import 'screens/home/driver_dashboard.dart';
import 'screens/wallet/wallet_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/ride/ride_history_page.dart';
import 'screens/map/map_select_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'services/supabase_service.dart';
import 'models/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  runApp(const IniatoApp());
}

class IniatoApp extends StatelessWidget {
  const IniatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iniato',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/role': (_) => const RoleSelectionPage(),
        '/wallet': (_) => const WalletPage(),
        '/profile': (_) => const ProfilePage(),
        '/history': (_) => const RideHistoryPage(),
        '/map': (_) => const MapSelectPage(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final SupabaseService _service = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return const LoginPage();
        }
        return FutureBuilder<UserProfile?>(
          future: _service.fetchMyProfile(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final profile = snap.data;
            if (profile == null || profile.role == null) {
              return const RoleSelectionPage();
            }
            if (profile.role == 'driver') {
              return const DriverDashboard();
            }
            return const PassengerDashboard();
          },
        );
      },
    );
  }
}
