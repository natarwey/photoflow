import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photoflow/database/models/photographer.dart';
import 'package:photoflow/database/models/user.dart' as app_user;
import 'package:photoflow/database/services/photographer_service.dart';
import 'package:photoflow/database/services/user_service.dart';
import 'package:photoflow/main.dart';
import 'package:photoflow/pages/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  
  final String fixedUserId = 'fe1511f5-4cea-42d9-9d51-289e0d5d54b4';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // try {
    //   final prefs = await SharedPreferences.getInstance();
    //   final userId = prefs.getString('userId');
    //   final photographerId = ModalRoute.of(context)!.settings.arguments as int;
    //   final photographer = await _photographerService.getPhotographerById(
    //     photographerId,
    //   );

    //   if (userId == null) {
    //     throw Exception("Пользователь не найден");
    //   }

    //   // Получаем данные пользователя
    //   final userData =
    //       await supabase.from('users').select().eq('id', userId).single();

    //   setState(() {
    //     user = app_user.User.fromJson(userData);
    //   });

    //   // Если это фотограф — загружаем доп информацию
    //   final photographerData =
    //       await supabase
    //           .from('photographers')
    //           .select()
    //           .eq('user_id', userId)
    //           .maybeSingle();
    //   if (photographerData != null) {
    //     Photographer photographer = Photographer.fromJson(photographerData);
    //     await PhotographerService().getPhotographerByUserId(
    //       userId,
    //     ); // Можно использовать уже готовый метод
    //     setState(() {
    //       photographer = photographer;
    //     });
    //   }

    setState(() {
      isLoading = true;
    });
    
    try {
      // Получаем данные пользователя по фиксированному ID
      final userData = await supabase
          .from('users')
          .select()
          .eq('id', fixedUserId)
          .single();

      if (userData == null || userData.isEmpty) {
        throw Exception("Данные пользователя пустые");
      }

      setState(() {
        user = app_user.User.fromJson(userData);
      });

      // Проверяем, является ли пользователь фотографом
      final photographerData = await supabase
          .from('photographers')
          .select()
          .eq('user_id', fixedUserId)
          .maybeSingle();

      if (photographerData != null) {
        final photographer = Photographer.fromJson(photographerData);
        // Загружаем дополнительную информацию о фотографе
        await _photographerService.loadAdditionalInfo([photographer]);
        setState(() {
          this.photographer = photographer;
        });
      }
    } catch (e) {
      print('Ошибка при загрузке данных пользователя: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Не удалось загрузить профиль: $e')),
      // );
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      //drawer: const DrawerWidget(),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              )
              : user == null
              ? const Center(
                child: Text(
                  'Не удалось загрузить данные пользователя',
                  style: TextStyle(fontSize: 18, color: Colors.black),
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
                          const SizedBox(height: 20),

                          // Email пользователя
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.email,
                                color: Color(0xFFFFD700),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                user!.email,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Дополнительная информация для фотографов
                          if (photographer != null) ...[
                            // Биография
                            if (photographer!.bio != null &&
                                photographer!.bio!.isNotEmpty) ...[
                              const Text(
                                'О фотографе',
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
                                  'Город: ${photographer!.cityTitle}' ?? 'Город не указан',
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
                            if (photographer!.socialLinks != null &&
                                photographer!.socialLinks!.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.link,
                                    color: Color(0xFFFFD700),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () async {
                                        final link = photographer!.socialLinks!;
                                        if (await canLaunchUrl(Uri.parse(link))) {
                                          await launchUrl(Uri.parse(link));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Не удалось открыть ссылку'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        photographer!.socialLinks!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ] else
                            const SizedBox(height: 20),

                          // Кнопка редактирования профиля
                          // OutlinedButton.icon(
                          //   onPressed: () {
                          //     // Навигация на страницу редактирования профиля
                          //   },
                          //   icon: const Icon(Icons.edit),
                          //   label: const Text('Редактировать профиль'),
                          //   style: OutlinedButton.styleFrom(
                          //     foregroundColor: Colors.black,
                          //     side: const BorderSide(
                          //       color: Color(0xFFFFD700),
                          //       width: 2,
                          //     ),
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 20,
                          //       vertical: 12,
                          //     ),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(20),
                          //     ),
                          //   ),
                          // ),
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
    } else if ([2, 3, 4].contains(years % 10) &&
        ![12, 13, 14].contains(years % 100)) {
      return 'года';
    } else {
      return 'лет';
    }
  }
}
