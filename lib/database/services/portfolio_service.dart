import 'package:flutter/foundation.dart';
import 'package:photoflow/database/models/location.dart';
import 'package:photoflow/database/models/mood.dart';
import 'package:photoflow/database/models/portfolio_item.dart';
import 'package:photoflow/main.dart';

class PortfolioService {
  Future<PortfolioItem> getRandomPortfolioItem() async {
    try {
      final response = await supabase
        .from('portfolio_items')
        .select('''
          *,
          photographers(user_id(name, surname)),
          genres!inner(title),
          mood!inner(title),
          location!inner(title)
        ''')
        .order('id')
        .limit(50);

      if (response.isEmpty) {
        throw Exception('Нет доступных элементов портфолио');
      }

      // Выбираем случайный элемент из полученных
      final random = DateTime.now().millisecondsSinceEpoch % response.length;
      final item = response[random];

      return PortfolioItem.fromJson(item);
    } catch (e) {
      print('Ошибка при получении случайного элемента портфолио: $e');
      throw Exception('Не удалось загрузить идею для съемки');
    }
  }

  Future<List<PortfolioItem>> getRandomPortfolioItemsByLocation(String locationId, int limit) async {
    try {
      final response = await supabase
          .from('portfolio_items')
          .select('''*, photographers(user_id(name, surname))''')
          .eq('location_id', locationId)
          .order('created_at', ascending: false)
          .limit(limit);

      List<PortfolioItem> portfolioItems = response.map<PortfolioItem>((item) => PortfolioItem.fromJson(item)).toList();

      await _loadAdditionalInfo(portfolioItems);

      return portfolioItems;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении портфолио по локации: $e');
      }
      return [];
    }
  }

  Future<List<PortfolioItem>> getPortfolioByPhotographerId(
    int photographerId,
  ) async {
    try {
      final response = await supabase
          .from('portfolio_items')
          .select('''
          *,
          photographers(user_id(name, surname))
        ''')
          .eq('photographer_id', photographerId)
          .order('created_at', ascending: false);

      List<PortfolioItem> portfolioItems =
          response
              .map<PortfolioItem>((item) => PortfolioItem.fromJson(item))
              .toList();

      // Загружаем дополнительную информацию для каждого элемента
      await _loadAdditionalInfo(portfolioItems);

      return portfolioItems;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении портфолио: $e');
      }
      return [];
    }
  }

  // Получение элементов портфолио по жанру
  Future<List<PortfolioItem>> getPortfolioByGenre(int genreId) async {
    try {
      final response = await supabase
        .from('portfolio_items')
        .select('''
          *,
          photographers(user_id(name, surname))
        ''')
        .eq('genre_id', genreId)
        .order('created_at', ascending: false);

      List<PortfolioItem> portfolioItems =
          response
              .map<PortfolioItem>((item) => PortfolioItem.fromJson(item))
              .toList();

      // Загружаем дополнительную информацию для каждого элемента
      await _loadAdditionalInfo(portfolioItems);

      return portfolioItems;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении портфолио по жанру: $e');
      }
      return [];
    }
  }

  // Получение конкретного элемента портфолио по ID
  Future<PortfolioItem?> getPortfolioItemById(int itemId) async {
    try {
      final response =
          await supabase
              .from('portfolio_items')
              .select()
              .eq('id', itemId)
              .single();

      PortfolioItem portfolioItem = PortfolioItem.fromJson(response);

      // Загружаем дополнительную информацию
      await _loadAdditionalInfo([portfolioItem]);

      return portfolioItem;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении элемента портфолио: $e');
      }
      return null;
    }
  }

  // Загрузка дополнительной информации для элементов портфолио
  Future<void> _loadAdditionalInfo(List<PortfolioItem> items) async {
    if (items.isEmpty) return;

    try {
      // Получаем уникальные ID жанров, настроений и локаций
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
      Set<String> userIds =
          items.map((item) => item.photographerId.toString()).toSet();

      // Загружаем пользователей
      if (userIds.isNotEmpty) {
        final usersResponse = await supabase
            .from('users')
            .select()
            .inFilter('id', userIds.toList());

        Map<String, Map<String, dynamic>> userMap = {};
        for (var user in usersResponse) {
          userMap[user['id']] = user;
        }

        // Присваиваем имя и фамилию к каждому элементу портфолио
        for (var item in items) {
          Map<String, dynamic>? user = userMap[item.photographerId.toString()];
          if (user != null) {
            item.photographerName = user['name'];
            item.photographerSurname = user['surname'];
          }
        }
      }

      // Загружаем жанры
      if (genreIds.isNotEmpty) {
        final genresResponse = await supabase
            .from('genres')
            .select()
            .inFilter('id', genreIds.toList());

        Map<int, String> genreMap = {};
        for (var genre in genresResponse) {
          genreMap[genre['id']] = genre['title'];
        }

        // Присваиваем названия жанров
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
          moodMap[mood['id']] = mood['title'];
        }

        // Присваиваем названия настроений
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
          locationMap[location['id']] = location['title'];
        }

        // Присваиваем названия локаций
        for (var item in items) {
          if (item.locationId != null) {
            item.locationTitle = locationMap[item.locationId];
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке дополнительной информации: $e');
      }
    }
  }

  // Получение всех настроений
  Future<List<Mood>> getMoods() async {
    try {
      final response = await supabase.from('mood').select().order('title');

      return response.map<Mood>((item) => Mood.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении настроений: $e');
      }
      return [];
    }
  }

  // Получение всех локаций
  Future<List<Location>> getLocations() async {
    try {
      final response = await supabase.from('location').select().order('title');

      return response.map<Location>((item) => Location.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении локаций: $e');
      }
      return [];
    }
  }
}
