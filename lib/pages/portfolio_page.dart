import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photoflow/database/models/photographer.dart';
import 'package:photoflow/database/models/portfolio_item.dart';
import 'package:photoflow/database/models/genre.dart';
import 'package:photoflow/database/models/mood.dart';
import 'package:photoflow/database/models/location.dart';
import 'package:photoflow/database/services/photographer_service.dart';
import 'package:photoflow/database/services/portfolio_service.dart';
import 'package:photoflow/database/services/genre_service.dart';
import 'package:photoflow/database/services/mood_service.dart';
import 'package:photoflow/database/services/location_service.dart';
import 'package:photoflow/main.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final PhotographerService _photographerService = PhotographerService();
  final PortfolioService _portfolioService = PortfolioService();
  final GenreService _genreService = GenreService();
  final MoodService _moodService = MoodService();
  final LocationService _locationService = LocationService();
  Photographer? photographer;
  List<PortfolioItem> portfolioItems = [];
  List<Genre> genres = [];
  List<Mood> moods = [];
  List<Location> locations = [];
  bool isLoading = true;
  bool isMyPortfolio = false;

  // Переменные для формы добавления фото
  bool isAddingPhoto = false;
  Uint8List? selectedImageBytes;
  String? selectedImageName;
  String photoTitle = '';
  Genre? selectedGenre;
  Mood? selectedMood;
  Location? selectedLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      final photographerId = arguments['photographerId'] as int;
      isMyPortfolio = arguments['isMyPortfolio'] as bool? ?? false;
      _loadData(photographerId);
    } else {
      // Старый способ передачи только ID
      final photographerId = arguments as int;
      _loadData(photographerId);
    }
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
      // Загружаем портфолио фотографа
      final portfolioData = await _portfolioService
          .getPortfolioByPhotographerId(photographerId);

      // Если это "Мое портфолио", загружаем данные для формы
      if (isMyPortfolio) {
        final genresData = await _genreService.getGenres();
        final moodsData = await _moodService.getMoods();
        final locationsData = await _locationService.getLocations();
        setState(() {
          genres = genresData;
          moods = moodsData;
          locations = locationsData;
        });
      }

      setState(() {
        photographer = photographerData;
        portfolioItems = portfolioData;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке данных: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            selectedImageBytes = file.bytes;
            selectedImageName = file.name;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка выбора файла: $e')),
        );
      }
    }
  }

  Future<void> _uploadPhoto() async {
    if (selectedImageBytes == null ||
        photoTitle.isEmpty ||
        selectedGenre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните все обязательные поля и выберите фото'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isAddingPhoto = true;
    });

    try {
      // Генерируем уникальное имя файла
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'portfolio/$fileName';

      // Загружаем файл в Supabase Storage
      await supabase.storage
          .from('portfolio')
          .uploadBinary(filePath, selectedImageBytes!);

      // Получаем публичную ссылку
      final imageUrl = supabase.storage
          .from('portfolio')
          .getPublicUrl(filePath);

      // Добавляем запись в базу данных
      // ИСПРАВЛЕНО: Используем photographer!.id (int), а не жестко заданное значение "2"
      await supabase.from('portfolio_items').insert({
        'photographer_id': photographer!.id, // <-- ИСПРАВЛЕНО: используем id текущего фотографа
        'image_url': imageUrl,
        'title': photoTitle,
        'genre_id': selectedGenre!.id,
        'mood_id': selectedMood?.id,
        'location_id': selectedLocation?.id, // <-- ИСПРАВЛЕНО: убрано int.parse, так как id уже int
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      // Обновляем список портфолио
      await _loadData(photographer!.id);

      // Очищаем форму
      setState(() {
        selectedImageBytes = null;
        selectedImageName = null;
        photoTitle = '';
        selectedGenre = null;
        selectedMood = null;
        selectedLocation = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Фото успешно добавлено!'),
            backgroundColor: Color.fromARGB(255, 139, 139, 139),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isAddingPhoto = false;
      });
    }
  }

  void _showAddPhotoDialog() {
    // Сбрасываем состояние формы
    selectedImageBytes = null;
    selectedImageName = null;
    photoTitle = '';
    selectedGenre = null;
    selectedMood = null;
    selectedLocation = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Добавить фото'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Превью изображения
                      if (selectedImageBytes != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color.fromARGB(255, 139, 139, 139)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              selectedImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('Фото не выбрано'),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Кнопка выбора фото
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _pickImage();
                          setDialogState(() {});
                        },
                        icon: const Icon(Icons.photo_library),
                        label: Text(selectedImageName ?? 'Выбрать фото'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 139, 139, 139),
                          foregroundColor: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Поле названия
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Название *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          photoTitle = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Выбор жанра
                      DropdownButtonFormField<Genre>(
                        decoration: const InputDecoration(
                          labelText: 'Жанр *',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedGenre,
                        items: genres.map((genre) {
                          return DropdownMenuItem<Genre>(
                            value: genre,
                            child: Text(genre.title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedGenre = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Выбор настроения
                      DropdownButtonFormField<Mood>(
                        decoration: const InputDecoration(
                          labelText: 'Настроение',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedMood,
                        items: moods.map((mood) {
                          return DropdownMenuItem<Mood>(
                            value: mood,
                            child: Text(mood.title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMood = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Выбор локации
                      DropdownButtonFormField<Location>(
                        decoration: const InputDecoration(
                          labelText: 'Локация',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedLocation,
                        items: locations.map((location) {
                          return DropdownMenuItem<Location>(
                            value: location,
                            child: Text(location.title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedLocation = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: isAddingPhoto ? null : () async {
                    await _uploadPhoto();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 139, 139, 139),
                    foregroundColor: Colors.black,
                  ),
                  child: isAddingPhoto
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadAdditionalInfo(List<PortfolioItem> items) async {
    if (items.isEmpty) return;
    try {
      // Загружаем уникальные ID жанров, настроений и локаций
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
                                color: Color.fromARGB(255, 139, 139, 139),
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
                                color: Color.fromARGB(255, 139, 139, 139),
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
                                color: Color.fromARGB(255, 139, 139, 139),
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
                                color: Color.fromARGB(255, 139, 139, 139),
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
              ? isMyPortfolio
                  ? 'Мое портфолио'
                  : 'Портфолио ${photographer!.name ?? ''} ${photographer!.surname ?? ''}'
              : 'Портфолио',
        ),
        backgroundColor: const Color.fromARGB(255, 139, 139, 139),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Кнопка добавления фото только для "Мое портфолио"
          if (isMyPortfolio)
            IconButton(
              onPressed: _showAddPhotoDialog,
              icon: const Icon(Icons.add_a_photo),
              tooltip: 'Добавить фото',
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color.fromARGB(255, 139, 139, 139)),
            )
          : portfolioItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Портфолио пустое'),
                      if (isMyPortfolio) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showAddPhotoDialog,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Добавить первое фото'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 139, 139, 139),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
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
                                borderRadius: const BorderRadius.vertical(
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
                                        color: Color.fromARGB(255, 139, 139, 139),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.error_outline,
                                        color: Color.fromARGB(255, 139, 139, 139),
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