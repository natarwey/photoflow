import 'package:flutter/foundation.dart';
import 'package:photoflow/database/models/photographer.dart';
import 'package:photoflow/database/models/user.dart' as app_user;
import 'package:photoflow/database/services/city_service.dart';
import 'package:photoflow/database/services/user_service.dart';
import 'package:photoflow/main.dart';

class PhotographerService {
  final UserService _userService = UserService();
  final CityService _cityService = CityService();

  // Получение всех фотографов
  Future<List<Photographer>> getAllPhotographers() async {
    try {
      final photographersData = await supabase.from('photographers').select('''
          *, 
          user_id(name, surname, avatar_url),
          city(title)
        ''');

      List<Photographer> photographers =
          photographersData.map<Photographer>((item) {
            final photographer = Photographer.fromJson(item);
            // Убедимся, что город загружается
            if (item['city'] != null) {
              photographer.cityTitle = item['city']['title'];
            }
            return photographer;
          }).toList();

      return photographers;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении всех фотографов: $e');
      }
      return [];
    }
  }

  // Получение фотографов по жанру
  Future<List<Photographer>> getPhotographersByGenre(int genreId) async {
    try {
      // Получаем ID фотографов, связанных с данным жанром
      final photographerGenres = await supabase
          .from('photographer_genres')
          .select('photographer_id')
          .eq('genre_id', genreId);

      if (photographerGenres.isEmpty) {
        return [];
      }

      // Извлекаем ID фотографов
      List<int> photographerIds =
          photographerGenres
              .map<int>((item) => item['photographer_id'] as int)
              .toList();

      // Получаем данные фотографов
      final photographersData = await supabase
          .from('photographers')
          .select('''
            *,
            user_id(name, surname)
          ''')
          .inFilter('id', photographerIds);

      List<Photographer> photographers =
          photographersData
              .map<Photographer>((item) => Photographer.fromJson(item))
              .toList();

      // Загружаем дополнительную информацию для каждого фотографа
      await loadAdditionalInfo(photographers);

      return photographers;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении фотографов по жанру: $e');
      }
      return [];
    }
  }

  // Получение фотографа по ID
  Future<Photographer?> getPhotographerById(int photographerId) async {
    try {
      final response =
          await supabase
              .from('photographers')
              .select('''
            *,
            user_id(name, surname, avatar_url)
          ''')
              .eq('id', photographerId)
              .single();

      Photographer photographer = Photographer.fromJson(response);

      // Загружаем дополнительную информацию
      await loadAdditionalInfo([photographer]);

      // Заполняем данные пользователя
      if (response['user_id'] != null) {
        photographer.name = response['user_id']['name'];
        photographer.surname = response['user_id']['surname'];
        photographer.avatarUrl = response['user_id']['avatar_url'];
      }

      return photographer;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении фотографа: $e');
      }
      return null;
    }
  }

  // Получение фотографа по ID пользователя
  Future<Photographer?> getPhotographerByUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception("ID пользователя не указан");
      }

      final response =
          await supabase
              .from('photographers')
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      Photographer photographer = Photographer.fromJson(response);

      // Загружаем дополнительную информацию
      await loadAdditionalInfo([photographer]);

      return photographer;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении фотографа по ID пользователя: $e');
      }
      return null;
    }
  }

  // Загрузка дополнительной информации для фотографов
  Future<void> loadAdditionalInfo(List<Photographer> photographers) async {
    if (photographers.isEmpty) return;

    try {
      Set<String> userIds = photographers.map((p) => p.userId).toSet();
      Set<int> cityIds = photographers.map((p) => p.cityId).toSet();

      // Получаем данные пользователей
      if (userIds.isNotEmpty) {
        final usersResponse = await supabase
            .from('users')
            .select('id, name, surname, avatar_url')
            .inFilter('id', userIds.toList());

        Map<String, Map<String, dynamic>> userMap = {};
        for (var userData in usersResponse) {
          userMap[userData['id'].toString()] = {
            'name': userData['name'],
            'surname': userData['surname'],
            'avatar_url': userData['avatar_url'],
          };
        }

        for (var photographer in photographers) {
          final userData = userMap[photographer.userId];
          if (userData != null) {
            photographer.name = userData['name'];
            photographer.surname = userData['surname'];
            photographer.avatarUrl = userData['avatar_url'];
          }
        }
      }

      // Получаем города
      if (cityIds.isNotEmpty) {
        final citiesResponse = await supabase
            .from('city')
            .select('id, title')
            .inFilter('id', cityIds.toList());

        Map<int, String> cityMap = {};
        for (var city in citiesResponse) {
          cityMap[city['id'] as int] = city['title'] as String;
        }

        for (var photographer in photographers) {
          photographer.cityTitle = cityMap[photographer.cityId];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'Ошибка при загрузке дополнительной информации для фотографов: $e',
        );
      }
    }
  }
}
