import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photoflow/database/models/photographer.dart';
import 'package:photoflow/database/models/user.dart' as app_user;
import 'package:photoflow/database/services/photographer_service.dart';
import 'package:photoflow/database/services/user_service.dart';
import 'package:photoflow/main.dart';
import 'package:photoflow/pages/drawer.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserService _userService = UserService();
  final PhotographerService _photographerService = PhotographerService();
  
  app_user.User? user;
  Photographer? photographer;
  bool isLoading = true;

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
      // Получаем текущего пользователя из Supabase Auth
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser != null) {
        // Получаем данные пользователя из таблицы users
        final userData = await supabase
            .from('users')
            .select()
            .eq('id', currentUser.id)
            .single();
        
        setState(() {
          user = app_user.User.fromJson(userData);
        });
        
        // Проверяем, является ли пользователь фотографом
        final photographerData = await _photographerService.getPhotographerByUserId(currentUser.id);
        
        if (photographerData != null) {
          setState(() {
            photographer = photographerData;
          });
        }
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
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD700),
        title: const Text(
          'Мой профиль',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: const DrawerWidget(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFD700),
              ),
            )
          : user == null
              ? const Center(
                  child: Text(
                    'Не удалось загрузить данные пользователя',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Аватар пользователя
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: user!.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null,
                            child: user!.avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFFFFD700),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 20),
                          
                          // Имя и фамилия пользователя
                          Text(
                            '${user!.name} ${user!.surname ?? ''}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          
                          // Email пользователя
                          Text(
                            user!.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // Информация о фотографе (если пользователь является фотографом)
                          if (photographer != null) ...[
                            const Divider(color: Colors.black26),
                            const SizedBox(height: 20),
                            
                            // Биография
                            if (photographer!.bio != null && photographer!.bio!.isNotEmpty) ...[
                              const Text(
                                'О себе',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                photographer!.bio!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                            ],
                            
                            // Город
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFFFFD700),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  photographer!.cityTitle ?? 'Неизвестно',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            
                            // Опыт
                            if (photographer!.experience != null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.work,
                                    color: Color(0xFFFFD700),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Опыт: ${photographer!.experience} ${_getYearsText(photographer!.experience!)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                            
                            // Цена
                            if (photographer!.price != null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.monetization_on,
                                    color: Color(0xFFFFD700),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Цена: ${photographer!.price} ₽',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                            
                            // Социальные сети
                            if (photographer!.socialLinks != null && photographer!.socialLinks!.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.link,
                                    color: Color(0xFFFFD700),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      photographer!.socialLinks!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                            
                            // Кнопка "Портфолио"
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/portfolio',
                                  arguments: photographer!.id,
                                );
                              },
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Мое портфолио'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 30),
                          
                          // Кнопка редактирования профиля
                          OutlinedButton.icon(
                            onPressed: () {
                              // Навигация на страницу редактирования профиля
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Редактировать профиль'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Color(0xFFFFD700), width: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
  
  String _getYearsText(int years) {
    if (years % 10 == 1 && years % 100 != 11) {
      return 'год';
    } else if ([2, 3, 4].contains(years % 10) && ![12, 13, 14].contains(years % 100)) {
      return 'года';
    } else {
      return 'лет';
    }
  }
}
