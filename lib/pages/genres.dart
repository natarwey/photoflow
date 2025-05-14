import 'package:flutter/material.dart';
import 'package:photoflow/database/models/city.dart';
import 'package:photoflow/database/models/genre.dart';
import 'package:photoflow/database/models/photographer.dart';
import 'package:photoflow/database/services/city_service.dart';
import 'package:photoflow/database/services/photographer_service.dart';

class GenresPage extends StatefulWidget {
  const GenresPage({super.key});

  @override
  State<GenresPage> createState() => _GenresPageState();
}

class _GenresPageState extends State<GenresPage> {
  final PhotographerService _photographerService = PhotographerService();
  final CityService _cityService = CityService();
  
  List<Photographer> photographers = [];
  List<City> cities = [];
  
  String searchQuery = '';
  City? selectedCity;
  RangeValues priceRange = const RangeValues(0, 10000);
  double minPrice = 0;
  double maxPrice = 10000;
  
  @override
  void initState() {
    super.initState();
    _loadCities();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final genre = ModalRoute.of(context)!.settings.arguments as Genre;
    _loadPhotographers(genre.id);
  }
  
  Future<void> _loadPhotographers(int genreId) async {
    try {
      final photographersList = await _photographerService.getPhotographersByGenre(genreId);
      setState(() {
        photographers = photographersList;
        
        // Определение минимальной и максимальной цены
        if (photographers.isNotEmpty) {
          minPrice = photographers
              .map((p) => p.price.toDouble())
              .reduce((a, b) => a < b ? a : b);
          maxPrice = photographers
              .map((p) => p.price.toDouble())
              .reduce((a, b) => a > b ? a : b);
          priceRange = RangeValues(minPrice, maxPrice);
        }
      });
    } catch (e) {
      print('Ошибка при загрузке фотографов: $e');
    }
  }
  
  Future<void> _loadCities() async {
    try {
      final citiesList = await _cityService.getCities();
      setState(() {
        cities = citiesList;
      });
    } catch (e) {
      print('Ошибка при загрузке городов: $e');
    }
  }
  
  List<Photographer> get filteredPhotographers {
    return photographers.where((photographer) {
      final nameMatches = photographer.name.toLowerCase().contains(searchQuery.toLowerCase());
      final cityMatches = selectedCity == null || photographer.cityId == selectedCity!.id;
      final priceMatches = photographer.price >= priceRange.start && photographer.price <= priceRange.end;
      
      return nameMatches && cityMatches && priceMatches;
    }).toList();
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Фильтры',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Город',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<City?>(
                      isExpanded: true,
                      value: selectedCity,
                      hint: const Text('Выберите город'),
                      items: [
                        const DropdownMenuItem<City?>(
                          value: null,
                          child: Text('Все города'),
                        ),
                        ...cities.map((city) {
                          return DropdownMenuItem<City?>(
                            value: city,
                            child: Text(city.title),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Диапазон цены',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: priceRange,
                      min: minPrice,
                      max: maxPrice,
                      divisions: 20,
                      activeColor: const Color(0xFFFFD700),
                      inactiveColor: Colors.grey[300],
                      labels: RangeLabels(
                        '${priceRange.start.round()} ₽',
                        '${priceRange.end.round()} ₽',
                      ),
                      onChanged: (values) {
                        setState(() {
                          priceRange = values;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${priceRange.start.round()} ₽'),
                        Text('${priceRange.end.round()} ₽'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Применить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final genre = ModalRoute.of(context)!.settings.arguments as Genre;
    
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD700),
        title: Text(
          genre.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Поиск фотографов',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFFFD700),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                    ),
                    cursorColor: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showFilterDialog,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredPhotographers.isEmpty
                ? const Center(
                    child: Text(
                      'Фотографы не найдены',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPhotographers.length,
                    itemBuilder: (context, index) {
                      final photographer = filteredPhotographers[index];
                      return InkWell(
                        onTap: () {
                          // Навигация на страницу профиля фотографа
                          Navigator.pushNamed(
                            context, 
                            '/photographer_profile',
                            arguments: photographer.id,
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Фото фотографа
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    photographer.avatarUrl ?? 'https://via.placeholder.com/80',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.person,
                                          color: Color(0xFFFFD700),
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Информация о фотографе
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        photographer.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Color(0xFFFFD700),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            cities.isNotEmpty 
                                                ? cities.firstWhere(
                                                    (city) => city.id == photographer.cityId,
                                                    orElse: () => City(
                                                      id: 0, 
                                                      createdAt: DateTime.now(),
                                                      title: 'Неизвестно',
                                                    ),
                                                  ).title
                                                : 'Неизвестно',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.monetization_on,
                                            color: Color(0xFFFFD700),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${photographer.price} ₽',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Стрелка вправо
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFFFFD700),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}