import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photoflow/database/models/photographer.dart';
import 'package:photoflow/database/models/user.dart' as app_user;
import 'package:photoflow/database/services/auth_service.dart';
import 'package:photoflow/database/services/user_service.dart';
import 'package:photoflow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  String userName = 'Пользователь';
  String userEmail = '';
  String? avatarUrl;
  bool isPhotographer = false;
  bool isLoading = true;

  // Фиксированный user_id для "Мое портфолио"
  final String fixedUserId = 'fe1511f5-4cea-42d9-9d51-289e0d5d54b4';
  app_user.User? user;
  Photographer? photographer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Получаем данные пользователя по фиксированному ID
      final userData =
          await supabase.from('users').select().eq('id', fixedUserId).single();

      if (userData == null || userData.isEmpty) {
        throw Exception("Данные пользователя пустые");
      }

      setState(() {
        user = app_user.User.fromJson(userData);
        userName = '${user!.name} ${user!.surname ?? ''}';
        userEmail = user!.email;
        avatarUrl = user!.avatarUrl;
      });

      // Проверяем, является ли пользователь фотографом
      final photographerData = await supabase
          .from('photographers')
          .select()
          .eq('user_id', fixedUserId)
          .maybeSingle();

      if (photographerData != null) {
        setState(() {
          photographer = Photographer.fromJson(photographerData);
          isPhotographer = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке данных пользователя: $e');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFEEEEEE),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/user_profile');
              },
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Color.fromARGB(255, 139, 139, 139)),
                accountName: Text(
                  isLoading ? 'Загрузка...' : userName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  isLoading ? '' : userEmail,
                  style: const TextStyle(color: Colors.black),
                ),
                currentAccountPicture: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl!)
                            : null,
                        child: avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Color.fromARGB(255, 139, 139, 139),
                              )
                            : null,
                      ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color.fromARGB(255, 139, 139, 139)),
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
                leading:
                    const Icon(Icons.photo_camera, color: Color.fromARGB(255, 139, 139, 139)),
                title: const Text(
                  'Мое портфолио',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  try {
                    // Получаем данные фотографа по фиксированному user_id
                    final photographerData = await supabase
                        .from('photographers')
                        .select()
                        .eq('user_id', fixedUserId)
                        .single();

                    final int photographerId = photographerData['id'];

                    // Переходим на страницу портфолио с флагом "Мое портфолио"
                    Navigator.pushNamed(
                      context,
                      '/portfolio',
                      arguments: {
                        'photographerId': photographerId,
                        'isMyPortfolio': true, // Важный флаг!
                      },
                    );
                  } catch (e) {
                    if (kDebugMode) {
                      print(
                          'Ошибка при переходе на страницу портфолио: $e');
                    }
                  }
                },
              ),
            ListTile(
              leading:
                  const Icon(Icons.location_on, color: Color.fromARGB(255, 139, 139, 139)),
              title: const Text(
                'Идеи поз',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/locations');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Color.fromARGB(255, 139, 139, 139)),
              title: const Text(
                'Избранные фото',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/favorites');
              },
            ),
            const Divider(color: Colors.black26),
            ListTile(
                  leading: const Icon(Icons.settings, color: Color.fromARGB(255, 139, 139, 139)),
                  title: Text(
                    'Настройки',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
            ListTile(
              leading:
                  const Icon(Icons.exit_to_app, color: Color.fromARGB(255, 139, 139, 139)),
              title: const Text('Выйти', style: TextStyle(color: Colors.black)),
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
