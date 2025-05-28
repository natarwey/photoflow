import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photoflow/database/models/city.dart';
import 'package:photoflow/database/models/genre.dart';
import 'package:photoflow/database/models/photographer.dart';
import 'package:photoflow/database/models/portfolio_item.dart';
import 'package:photoflow/database/services/city_service.dart';
import 'package:photoflow/database/services/photographer_service.dart';
import 'package:photoflow/database/services/portfolio_service.dart';
import 'package:photoflow/main.dart';

class GenresPage extends StatefulWidget {
  const GenresPage({super.key});

  @override
  State<GenresPage> createState() => _GenresPageState();
}

class _GenresPageState extends State<GenresPage> {
  final PhotographerService _photographerService = PhotographerService();
  final CityService _cityService = CityService();
  final PortfolioService _portfolioService = PortfolioService();

  List<Photographer> photographers = [];
  List<PortfolioItem> portfolioItems = [];
  List<City> cities = [];

  String searchQuery = '';
  City? selectedCity;
  RangeValues priceRange = const RangeValues(0, 10000);
  double minPrice = 0;
  double maxPrice = 10000;
  bool isLoadingPhotographers = true;
  bool isLoadingPortfolio = true;
  int _currentTabIndex = 0;

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
    _loadPortfolioItems(genre.id);
  }

  Future<void> _loadPhotographers(int genreId) async {
    setState(() {
      isLoadingPhotographers = true;
    });

    try {
      // Загружаем всех фотографов
      final photographersList =
          await _photographerService.getAllPhotographers();
      setState(() {
        photographers = photographersList;

        // Определение минимальной и максимальной цены
        if (photographers.isNotEmpty) {
          List<int> prices =
              photographers
                  .where((p) => p.price != null)
                  .map((p) => p.price!)
                  .toList();

          if (prices.isNotEmpty) {
            minPrice = prices.reduce((a, b) => a < b ? a : b).toDouble();
            maxPrice = prices.reduce((a, b) => a > b ? a : b).toDouble();
            priceRange = RangeValues(minPrice, maxPrice);
          }
        }

        isLoadingPhotographers = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке фотографов: $e');
      }
      setState(() {
        isLoadingPhotographers = false;
      });
    }
  }

  Future<void> _loadPortfolioItems(int genreId) async {
    setState(() {
      isLoadingPortfolio = true;
    });

    try {
      final items = await _portfolioService.getPortfolioByGenre(genreId);
      await _loadAdditionalInfo(items);
      setState(() {
        portfolioItems = items;
        isLoadingPortfolio = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке портфолио: $e');
      }
      setState(() {
        isLoadingPortfolio = false;
      });
    }
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
      final nameMatches =
          photographer.name != null &&
          photographer.name!.toLowerCase().contains(searchQuery.toLowerCase());
      final surnameMatches =
          photographer.surname != null &&
          photographer.surname!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
      final cityMatches =
          selectedCity == null || photographer.cityId == selectedCity!.id;
      final priceMatches =
          photographer.price == null ||
          (photographer.price! >= priceRange.start &&
              photographer.price! <= priceRange.end);

      return (nameMatches || surnameMatches) && cityMatches && priceMatches;
    }).toList();
  }

  List<PortfolioItem> get filteredPortfolioItems {
    return portfolioItems.where((item) {
      return item.title.toLowerCase().contains(searchQuery.toLowerCase());
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
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
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
                      hintText:
                          _currentTabIndex == 0
                              ? 'Поиск фотографов'
                              : 'Поиск фотографий',
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
                    child: const Icon(Icons.filter_list, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      tabs: const [
                        Tab(icon: Icon(Icons.person), text: 'Фотографы'),
                        Tab(
                          icon: Icon(Icons.photo_library),
                          text: 'Фотографии',
                        ),
                      ],
                      labelColor: const Color(0xFFFFD700),
                      unselectedLabelColor: Colors.black54,
                      indicatorColor: const Color(0xFFFFD700),
                      onTap: (index) {
                        setState(() {
                          _currentTabIndex = index;
                          // Сбрасываем поисковый запрос при переключении вкладок
                          searchQuery = '';
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Вкладка с фотографами
                        isLoadingPhotographers
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFD700),
                              ),
                            )
                            : filteredPhotographers.isEmpty
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
                                final photographer =
                                    filteredPhotographers[index];
                                return InkWell(
                                  onTap: () {
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              photographer.avatarUrl ??
                                                  'https://via.placeholder.com/80',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${photographer.name ?? ''} ${photographer.surname ?? ''}',
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
                                                      photographer.cityTitle ??
                                                          'Неизвестно',
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                if (photographer.price !=
                                                    null) ...[
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.monetization_on,
                                                        color: Color(
                                                          0xFFFFD700,
                                                        ),
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${photographer.price} ₽',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[700],
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
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

                        // Вкладка с фотографиями
                        isLoadingPortfolio
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFD700),
                              ),
                            )
                            : filteredPortfolioItems.isEmpty
                            ? const Center(
                              child: Text(
                                'Фотографии не найдены',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            )
                            : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: filteredPortfolioItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredPortfolioItems[index];
                                return InkWell(
                                  onTap: () => _showPortfolioItemDetails(item),
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                if (loadingProgress == null)
                                                  return child;
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Color(
                                                          0xFFFFD700,
                                                        ),
                                                      ),
                                                );
                                              },
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
