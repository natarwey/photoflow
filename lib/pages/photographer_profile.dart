import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photoflow/database/models/photographer.dart';
import 'package:photoflow/database/services/photographer_service.dart';

class PhotographerProfilePage extends StatefulWidget {
  const PhotographerProfilePage({super.key});

  @override
  State<PhotographerProfilePage> createState() => _PhotographerProfilePageState();
}

class _PhotographerProfilePageState extends State<PhotographerProfilePage> {
  final PhotographerService _photographerService = PhotographerService();
  
  Photographer? photographer;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final photographerId = ModalRoute.of(context)!.settings.arguments as int;
    _loadPhotographerData(photographerId);
  }

  Future<void> _loadPhotographerData(int photographerId) async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final photographerData = await _photographerService.getPhotographerById(photographerId);
      
      setState(() {
        photographer = photographerData;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке данных фотографа: $e');
      }
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
        title: Text(
          photographer != null
              ? '${photographer!.name ?? ''} ${photographer!.surname ?? ''}'
              : 'Профиль фотографа',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFD700),
              ),
            )
          : photographer == null
              ? const Center(
                  child: Text(
                    'Не удалось загрузить данные фотографа',
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
                          // Аватар фотографа
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: photographer!.avatarUrl != null
                                ? NetworkImage(photographer!.avatarUrl!)
                                : null,
                            child: photographer!.avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFFFFD700),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 20),
                          
                          // Имя и фамилия фотографа
                          Text(
                            '${photographer!.name ?? ''} ${photographer!.surname ?? ''}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          
                          // Биография
                          if (photographer!.bio != null && photographer!.bio!.isNotEmpty) ...[
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
                            label: const Text('Портфолио'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Кнопка "Добавить в избранное"
                          OutlinedButton.icon(
                            onPressed: () {
                              // Добавление в избранное
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Добавлено в избранное',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor: Color(0xFFFFD700),
                                ),
                              );
                            },
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Добавить в избранное'),
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
