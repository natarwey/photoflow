import 'package:flutter/material.dart';
import 'package:photoflow/database/models/location.dart';
import 'package:photoflow/database/models/portfolio_item.dart';
import 'package:photoflow/database/services/location_service.dart';
import 'package:photoflow/database/services/portfolio_service.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({Key? key}) : super(key: key);

  @override
  _LocationsPageState createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  final LocationService _locationService = LocationService();
  final PortfolioService _portfolioService = PortfolioService();

  List<Location> locations = [];
  Location? selectedLocation;
  List<PortfolioItem> photos = [];
  List<int> loadedPhotoIds = []; // Храним ID уже загруженных фото
  int currentPhotoIndex = 0; // Текущий индекс отображаемого фото
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    try {
      final fetchedLocations = await _locationService.getLocations();
      setState(() {
        locations = fetchedLocations;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при загрузке локаций: $e')),
        );
      }
    }
  }

  Future<void> _fetchRandomPhotos(String locationId, int limit) async {
    try {
      print('Запрос фото для локации $locationId с лимитом $limit');
      final fetchedPhotos = await _portfolioService.getRandomPortfolioItemsByLocation(locationId, limit);
      print('Получено фото: ${fetchedPhotos.length}');
      // Логируем ID полученных фото
      print('ID полученных фото: ${fetchedPhotos.map((p) => p.id).toList()}');

      // Фильтруем, чтобы исключить повторные фото
      List<PortfolioItem> uniquePhotos = fetchedPhotos.where((photo) {
        return !loadedPhotoIds.contains(photo.id);
      }).toList();

      print('После фильтрации уникальных фото: ${uniquePhotos.length}');

      if (uniquePhotos.isEmpty) {
        print('Нет новых фото для локации $locationId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Еще идей на этой локации пока нет'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        photos.addAll(uniquePhotos);
        loadedPhotoIds.addAll(uniquePhotos.map((p) => p.id));
      });
    } catch (e) {
      if (mounted) {
        print('Ошибка при загрузке фото: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки фото: $e')),
        );
      }
    }
  }

  void _handleLocationChange(Location? location) {
    if (location != null) {
      setState(() {
        selectedLocation = location;
        photos.clear();
        loadedPhotoIds.clear();
        currentPhotoIndex = 0; // Сбрасываем индекс
        _fetchRandomPhotos(location.id, 3); // Загружаем 3 фото сразу
      });
    }
  }

  void _loadMorePhotos() {
    if (selectedLocation != null && currentPhotoIndex < photos.length - 1) {
      setState(() {
        currentPhotoIndex++; // Переходим к следующему фото
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('На этой локации больше нет идей'),
        ),
      );
    }
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return 1;
    if (screenWidth < 900) return 2;
    return 3;
  }

  String fixImageUrl(String url) {
    return url.replaceAll('//', '/');
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFEEEEEE),
    appBar: AppBar(
      title: const Text('Идеи поз'),
      backgroundColor: const Color.fromARGB(255, 139, 139, 139),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 139, 139, 139)))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<Location>(
                        isExpanded: true,
                        value: selectedLocation,
                        hint: const Text('Выберите локацию'),
                        items: locations.map((location) {
                          return DropdownMenuItem<Location>(
                            value: location,
                            child: Text(location.title),
                          );
                        }).toList(),
                        onChanged: _handleLocationChange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: selectedLocation != null && currentPhotoIndex < photos.length - 1
                          ? _loadMorePhotos
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 139, 139, 139),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Еще'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (photos.isNotEmpty)
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _calculateCrossAxisCount(context),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: currentPhotoIndex + 1,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            fixImageUrl(photo.imageUrl!),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(color: Color.fromARGB(255, 139, 139, 139)),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (photos.isEmpty && !isLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
  );
}
}