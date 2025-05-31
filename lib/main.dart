import 'package:flutter/material.dart';
import 'package:photoflow/pages/auth.dart';
import 'package:photoflow/pages/genres.dart';
import 'package:photoflow/pages/home.dart';
import 'package:photoflow/pages/photographer_profile.dart';
import 'package:photoflow/pages/portfolio_page.dart';
import 'package:photoflow/pages/poses.dart';
import 'package:photoflow/pages/recovery.dart';
import 'package:photoflow/pages/reg.dart';
import 'package:photoflow/pages/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    
  await Supabase.initialize(
    url: 'https://cmtphdehmvxvbkiawahb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNtdHBoZGVobXZ4dmJraWF3YWhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ2MjEwMzIsImV4cCI6MjA2MDE5NzAzMn0.G5MtKiun49tdjJTm-h6j9QqlS5C7HY3p4taOkcZ5_5Q',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PhotoFlow',
      theme: ThemeData(
        primaryColor: const Color(0xFFFFD700), // Золотой цвет #FFD700
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          primary: const Color(0xFFFFD700),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700), // Золотой цвет для кнопок
            foregroundColor: Colors.black, // Черный текст на кнопках
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFFFD700)), // Золотая обводка
            foregroundColor: Colors.black, // Черный текст
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFFFD700)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFFFD700)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthPage(),
        '/auth': (context) => const AuthPage(),
        '/reg': (context) => const RegPage(),
        '/recovery': (context) => const RecoveryPage(),
        '/home': (context) => const HomePage(),
        '/genres': (context) => const GenresPage(),
        '/photographer_profile': (context) => const PhotographerProfilePage(),
        '/poses': (context) => const PosesPage(),
        '/user_profile': (context) => const UserProfilePage(),
        '/portfolio': (context) => const PortfolioPage(),
      },
    );
  }
}

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  bool isLoggedIn = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFD700),
          ),
        ),
      );
    }
    
    if (isLoggedIn) {
      return const HomePage();
    } else {
      return const AuthPage();
    }
  }
}
