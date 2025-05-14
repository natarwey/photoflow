import 'package:flutter/material.dart';
import 'package:photoflow/database/services/auth_service.dart';
import 'package:photoflow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final AuthService _authService = AuthService();
  String userName = 'Пользователь';
  String userEmail = '';
  String? avatarUrl;
  bool isPhotographer = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkUserType();
  }
  
  Future<void> _loadUserData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        // Получаем данные пользователя из таблицы users
        final userData = await supabase
            .from('users')
            .select('name, surname, email, avatar_url')
            .eq('id', userId)
            .single();
        
        setState(() {
          userName = '${userData['name']} ${userData['surname'] ?? ''}';
          userEmail = userData['email'] ?? '';
          avatarUrl = userData['avatar_url'];
        });
      }
    } catch (e) {
      print('Ошибка при загрузке данных пользователя: $e');
    }
  }
  
  Future<void> _checkUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPhotographer = prefs.getBool('isPhotographer') ?? false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFEEEEEE),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
              ),
              accountName: Text(
                userName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                userEmail,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFFFFD700),
                      )
                    : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFFFFD700)),
              title: const Text(
                'Главная',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            if (isPhotographer)
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFFFFD700)),
                title: const Text(
                  'Мое портфолио',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Навигация на страницу портфолио
                },
              ),
            ListTile(
              leading: const Icon(Icons.accessibility, color: Color(0xFFFFD700)),
              title: const Text(
                'Позы',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                // Навигация на страницу поз
                Navigator.pushNamed(context, '/poses');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFFFFD700)),
              title: const Text(
                'Профиль',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                // Навигация на страницу профиля
              },
            ),
            const Divider(color: Colors.black26),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Color(0xFFFFD700)),
              title: const Text(
                'Выйти',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () async {
                await _authService.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                Navigator.popAndPushNamed(context, '/auth');
              },
            ),
          ],
        ),
      ),
    );
  }
}