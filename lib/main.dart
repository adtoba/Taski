import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taski/core/utils/dimensions.dart';
import 'package:taski/firebase_options.dart';
import 'package:taski/presentation/features/auth/screens/auth_screen.dart';
import 'package:taski/presentation/features/dashboard/screens/dashboard_layout.dart';

final config = SizeConfig();
final navigatorKey = GlobalKey<NavigatorState>();
final logger = Logger();

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const ProviderScope(child: MyApp()));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taski',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          surfaceTintColor: const Color(0xFF1A1A1A),
          elevation: 4,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
          ),
          centerTitle: true,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
          ),
          bodySmall: TextStyle(
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            color: Colors.white,
          ),
          titleSmall: TextStyle(
            color: Colors.white,
          )
        ),
      ),
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 4,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black87,
          ),
          titleTextStyle: TextStyle(
            color: Colors.black87,
          ),
          centerTitle: true,
        ),  
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(
            color: Colors.black87,
          ),
          bodySmall: TextStyle(
            color: Colors.black87,
          ),
          titleLarge: TextStyle(
            color: Colors.black87,
          ),
          titleMedium: TextStyle(
            color: Colors.black87,
          ),
          titleSmall: TextStyle(
            color: Colors.black87,
          ),
          headlineSmall: TextStyle(
            color: Colors.black87,
          ),
          headlineMedium: TextStyle(
            color: Colors.black87,
          ),
          headlineLarge: TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
      navigatorKey: navigatorKey,
      home: Builder(
        builder: (context) {
          SizeConfig.init(context);
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return const DashboardLayout();
          }
          return AuthScreen();
        }
      )
    );
  }
}