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
      final photographersData = await supabase
          .from('photographers')
          .select();
      
      List<Photographer> photographers = photographersData.map<Photographer>((item) => Photographer.fromJson(item)).toList();
      
      // Загружаем дополнительную информацию для каждого фотографа
      await _loadAdditionalInfo(photographers);
      
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
      List<int> photographerIds = photographerGenres.map<int>((item) => item['photographer_id'] as int).toList();
      
      // Получаем данные фотографов
      final photographersData = await supabase
          .from('photographers')
          .select()
          .inFilter('id', photographerIds);
      
      List<Photographer> photographers = photographersData.map<Photographer>((item) => Photographer.fromJson(item)).toList();
      
      // Загружаем дополнительную информацию для каждого фотографа
      await _loadAdditionalInfo(photographers);
      
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
      final response = await supabase
          .from('photographers')
          .select()
          .eq('id', photographerId)
          .single();
      
      Photographer photographer = Photographer.fromJson(response);
      
      // Загружаем дополнительную информацию
      await _loadAdditionalInfo([photographer]);
      
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
      final response = await supabase
          .from('photographers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      Photographer photographer = Photographer.fromJson(response);
      
      // Загружаем дополнительную информацию
      await _loadAdditionalInfo([photographer]);
      
      return photographer;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении фотографа по ID пользователя: $e');
      }
      return null;
    }
  }
  
  // Загрузка дополнительной информации для фотографов
  Future<void> _loadAdditionalInfo(List<Photographer> photographers) async {
    if (photographers.isEmpty) return;
    
    try {
      // Получаем уникальные ID пользователей и городов
      Set<String> userIds = photographers.map((p) => p.userId).toSet();
      Set<int> cityIds = photographers.map((p) => p.cityId).toSet();
      
      // Загружаем данные пользователей
      final usersData = await supabase
          .from('users')
          .select()
          .inFilter('id', userIds.toList());
      
      Map<String, app_user.User> userMap = {};
      for (var userData in usersData) {
        userMap[userData['id']] = app_user.User.fromJson(userData);
      }
      
      // Загружаем данные городов
      final citiesData = await supabase
          .from('city')
          .select()
          .inFilter('id', cityIds.toList());
      
      Map<int, String> cityMap = {};
      for (var cityData in citiesData) {
        cityMap[cityData['id']] = cityData['title'];
      }
      
      // Присваиваем данные пользователей и городов фотографам
      for (var photographer in photographers) {
        if (userMap.containsKey(photographer.userId)) {
          photographer.name = userMap[photographer.userId]!.name;
          photographer.surname = userMap[photographer.userId]!.surname;
          photographer.avatarUrl = userMap[photographer.userId]!.avatarUrl;
        }
        
        if (cityMap.containsKey(photographer.cityId)) {
          photographer.cityTitle = cityMap[photographer.cityId];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке дополнительной информации для фотографов: $e');
      }
    }
  }
}
