import 'package:flutter/material.dart';
import 'package:photoflow/pages/auth.dart';
import 'package:photoflow/pages/favorites.dart';
import 'package:photoflow/pages/genres.dart';
import 'package:photoflow/pages/home.dart';
import 'package:photoflow/pages/locations.dart';
import 'package:photoflow/pages/photographer_profile.dart';
import 'package:photoflow/pages/portfolio_page.dart';
import 'package:photoflow/pages/recovery.dart';
import 'package:photoflow/pages/reg.dart';
import 'package:photoflow/pages/settings.dart';
import 'package:photoflow/pages/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    
  await Supabase.initialize(
    url: 'https://cmtphdehmvxvbkiawahb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNtdHBoZGVobXZ4dmJraWF3YWhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ2MjEwMzIsImV4cCI6MjA2MDE5NzAzMn0.G5MtKiun49tdjJTm-h6j9QqlS5C7HY3p4taOkcZ5_5Q',
  );
  
  // Загружаем сохраненную тему при запуске
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  
  runApp(MyApp(isDarkMode: isDarkMode));
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  late ThemeData _theme;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    //_updateTheme();
  }

  // void _updateTheme() {
  //   setState(() {
  //     _theme = ThemeData(
  //       brightness: _isDarkMode ? Brightness.dark : Brightness.light,
  //       primaryColor: const Color(0xFFFF6B6B),
  //       colorScheme: ColorScheme.fromSeed(
  //         seedColor: const Color(0xFFFF6B6B),
  //         primary: const Color(0xFFFF6B6B),
  //         brightness: _isDarkMode ? Brightness.dark : Brightness.light,
  //       ),
  //       textTheme: TextTheme(
  //         bodyMedium: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
  //         bodyLarge: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
  //       ),
  //       elevatedButtonTheme: ElevatedButtonThemeData(
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: const Color(0xFFFF6B6B),
  //           foregroundColor: Colors.black,
  //         ),
  //       ),
  //       outlinedButtonTheme: OutlinedButtonThemeData(
  //         style: OutlinedButton.styleFrom(
  //           side: const BorderSide(color: Color(0xFFFF6B6B)),
  //           foregroundColor: _isDarkMode ? Colors.white : Colors.black,
  //         ),
  //       ),
  //       inputDecorationTheme: InputDecorationTheme(
  //         labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(20),
  //           borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(20),
  //           borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
  //         ),
  //       ),
  //       scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
  //     );
  //   });
  // }

  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _isDarkMode = isDark;
      //_updateTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      title: 'PhotoFlow',
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthPage(),
        '/auth': (context) => const AuthPage(),
        '/reg': (context) => const RegPage(),
        '/recovery': (context) => const RecoveryPage(),
        '/home': (context) => const HomePage(),
        '/genres': (context) => const GenresPage(),
        '/photographer_profile': (context) => const PhotographerProfilePage(),
        '/favorites': (context) => const FavoritesPage(),        
        '/locations': (context) => const LocationsPage(),
        '/user_profile': (context) => const UserProfilePage(),
        '/portfolio': (context) => const PortfolioPage(),
        '/settings': (context) => SettingsPage(
              onThemeChanged: _toggleTheme,
              initialDarkMode: _isDarkMode,
            ),
      },
    );
  }
}

ThemeData _buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFFF6B6B),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFFFF6B6B),
      secondary: const Color(0xFFFF6B6B),
      surface: const Color(0xFFF8F9FA),
      background: const Color(0xFFF8F9FA),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color(0xFFFF6B6B)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color(0xFFFF6B6B)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color(0xFFFF6B6B), width: 2),
      ),
      labelStyle: TextStyle(color: Colors.black54),
    ),
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData.dark().copyWith(
    primaryColor: const Color(0xFFFF6B6B),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFFFF6B6B),
      secondary: const Color(0xFFFF6B6B),
      surface: const Color(0xFF121212),
      background: const Color(0xFF121212),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color(0xFFFF6B6B)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color(0xFFFF6B6B)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color(0xFFFF6B6B), width: 2),
      ),
      labelStyle: TextStyle(color: Colors.white70),
    ),
    // cardTheme: CardTheme(
    //   color: const Color(0xFF1E1E1E),
    //   margin: EdgeInsets.zero,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(12),
    //   ),
    // ),
  );
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
            color: Color(0xFFFF6B6B),
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