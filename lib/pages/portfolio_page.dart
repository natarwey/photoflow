import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photoflow/database/models/photographer.dart';
import 'package:photoflow/database/models/portfolio_item.dart';
import 'package:photoflow/database/services/photographer_service.dart';
import 'package:photoflow/database/services/portfolio_service.dart';
import 'package:photoflow/main.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final PhotographerService _photographerService = PhotographerService();
  final PortfolioService _portfolioService = PortfolioService();

  Photographer? photographer;
  List<PortfolioItem> portfolioItems = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final photographerId = ModalRoute.of(context)!.settings.arguments as int;
    _loadData(photographerId);
  }

  Future<void> _loadData(int photographerId) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Загружаем данные фотографа
      final photographerData = await _photographerService.getPhotographerById(
        photographerId,
      );

      // Загружаем портфолио фотографаЫ
      final portfolioData = await _portfolioService
          .getPortfolioByPhotographerId(photographerId);

      setState(() {
        photographer = photographerData;
        portfolioItems = portfolioData;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке данных: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAdditionalInfo(List<PortfolioItem> items) async {
    if (items.isEmpty) return;

    try {
      Set<int> genreIds = items.map((item) => item.genreId).toSet();
      Set<int?> moodIds =
          items
              .map((item) => item.moodId)
              .where((id) => id != null)
              .cast<int>()
              .toSet();
      Set<int?> locationIds =
          items
              .map((item) => item.locationId)
              .where((id) => id != null)
              .cast<int>()
              .toSet();

      // Загружаем жанры
      if (genreIds.isNotEmpty) {
        final genresResponse = await supabase
            .from('genres')
            .select()
            .inFilter('id', genreIds.toList());
        Map<int, String> genreMap = {};
        for (var genre in genresResponse) {
          genreMap[genre['id'] as int] = genre['title'] as String;
        }
        for (var item in items) {
          item.genreTitle = genreMap[item.genreId];
        }
      }

      // Загружаем настроения
      if (moodIds.isNotEmpty) {
        final moodsResponse = await supabase
            .from('mood')
            .select()
            .inFilter('id', moodIds.toList());
        Map<int, String> moodMap = {};
        for (var mood in moodsResponse) {
          moodMap[mood['id'] as int] = mood['title'] as String;
        }
        for (var item in items) {
          if (item.moodId != null) {
            item.moodTitle = moodMap[item.moodId];
          }
        }
      }

      // Загружаем локации
      if (locationIds.isNotEmpty) {
        final locationsResponse = await supabase
            .from('location')
            .select()
            .inFilter('id', locationIds.toList());
        Map<int, String> locationMap = {};
        for (var location in locationsResponse) {
          locationMap[location['id'] as int] = location['title'] as String;
        }
        for (var item in items) {
          if (item.locationId != null) {
            item.locationTitle = locationMap[item.locationId];
          }
        }
      }
    } catch (e) {
      print('Ошибка при загрузке дополнительной информации: $e');
    }
  }

  void _showPortfolioItemDetails(PortfolioItem item) {
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.photographerSurname ?? ''} ${item.photographerName ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (item.genreTitle != null) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.photo_album,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Жанр: ${item.genreTitle ?? "Не указан"}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (item.moodTitle != null) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.mood,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Настроение: ${item.moodTitle ?? "Не указано"}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (item.locationTitle != null) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Локация: ${item.locationTitle ?? "Не указана"}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ],
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
        title: Text(
          photographer != null
              ? 'Портфолио ${photographer!.name ?? ''} ${photographer!.surname ?? ''}'
              : 'Портфолио',
        ),
        backgroundColor: const Color(0xFFFFD700),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              )
              : portfolioItems.isEmpty
              ? const Center(child: Text('Портфолио пустое'))
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: portfolioItems.length,
                itemBuilder: (context, index) {
                  final item = portfolioItems[index];
                  return InkWell(
                    onTap: () => _showPortfolioItemDetails(item),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Квадратное фото
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFFD700),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: Color(0xFFFFD700),
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.photographerSurname ?? ''} ${item.photographerName ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}