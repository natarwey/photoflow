import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photoflow/database/models/genre.dart';
import 'package:photoflow/database/models/portfolio_item.dart';
import 'package:photoflow/database/services/auth_service.dart';
import 'package:photoflow/database/services/genre_service.dart';
import 'package:photoflow/database/services/portfolio_service.dart';
import 'package:photoflow/pages/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final PortfolioService _portfolioService = PortfolioService();
  final GenreService _genreService = GenreService();
  bool isPhotographer = false;
  PortfolioItem? currentIdea;
  bool isLoadingIdea = true;
  List<Genre> genres = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkUserType();
    _loadRandomIdea();
    _loadGenres();

    // Обновление идеи каждые 5 минут
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _loadRandomIdea();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPhotographer = prefs.getBool('isPhotographer') ?? false;
    });
  }

  Future<void> _loadRandomIdea() async {
    setState(() {
      isLoadingIdea = true;
    });

    try {
      final idea = await _portfolioService.getRandomPortfolioItem();
      setState(() {
        currentIdea = idea;
        isLoadingIdea = false;
      });
    } catch (e) {
      print('Ошибка при загрузке идеи: $e');
      setState(() {
        currentIdea = null;
        isLoadingIdea = false;
      });
    }
  }

  Future<void> _loadGenres() async {
    try {
      final genresList = await _genreService.getGenres();
      setState(() {
        genres = genresList;
      });
    } catch (e) {
      print('Ошибка при загрузке жанров: $e');
    }
  }

  // Метод для открытия карточки фотографии
  void _showPortfolioItemDetails(PortfolioItem item) {
    print('DEBUG: Открываем детали фото:');

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Color(0xFFFFD700),
                                size: 50,
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (item.photographerSurname != null ||
                            item.photographerName != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.photographerSurname ?? ''} ${item.photographerName ?? ''}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/photographer_profile',
                                    arguments: item.photographerId,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD700),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(fontSize: 10),
                                ),
                                child: const Text('Профиль'),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        if (item.genreTitle != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.photo_album,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Жанр: ${item.genreTitle}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        if (item.moodTitle != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.mood,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Настроение: ${item.moodTitle}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        if (item.locationTitle != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Локация: ${item.locationTitle}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
      ),
      drawer: const DrawerWidget(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Твоя идея для съёмки',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Картинка идеи
              if (currentIdea != null)
                GestureDetector(
                  onTap: () => _showPortfolioItemDetails(currentIdea!),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(currentIdea!.imageUrl),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Image.network(
                            currentIdea!.imageUrl,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 250,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 250,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFFFD700),
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                  ),
                ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD700)),
                ),
                child: Text(
                  currentIdea?.moodTitle ?? 'Нет настроения',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),
              const Text(
                'Выбрать фотографа по жанру',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5,
                ),
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/genres',
                        arguments: genres[index],
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      genres[index].title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
