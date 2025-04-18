import 'package:flutter/material.dart';
import 'package:photoflow/database/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  bool isPhotographer = false;
  
  @override
  void initState() {
    super.initState();
    _checkUserType();
  }
  
  Future<void> _checkUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPhotographer = prefs.getBool('isPhotographer') ?? false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD700),
        title: const Text(
          'Главная',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await _authService.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              Navigator.popAndPushNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Добро пожаловать!',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPhotographer ? 'Вы зарегистрированы как фотограф' : 'Вы зарегистрированы как клиент',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 40),
            const Text(
              'Здесь будет основной функционал приложения',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}