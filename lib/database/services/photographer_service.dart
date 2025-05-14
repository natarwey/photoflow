import 'package:photoflow/database/models/photographer.dart';
import 'package:photoflow/main.dart';

class PhotographerService {
  Future<List<Photographer>> getPhotographersByGenre(int genreId) async {
    try {
      final response = await supabase
          .from('photographers')
          .select('*, users!inner(*)')
          .eq('photographer_genres.genre_id', genreId);
          //.in_('id', supabase.from('photographer_genres').select('photographer_id').eq('genre_id', genreId));
      
      return response.map<Photographer>((json) => Photographer.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при получении фотографов по жанру: $e');
      return [];
    }
  }
  
  Future<Photographer?> getPhotographerById(int id) async {
    try {
      final response = await supabase
          .from('photographers')
          .select('*, users!inner(*)')
          .eq('id', id)
          .single();
      
      return Photographer.fromJson(response);
    } catch (e) {
      print('Ошибка при получении фотографа: $e');
      return null;
    }
  }
  
  Future<List<Photographer>> searchPhotographers(String query, {int? cityId, double? minPrice, double? maxPrice}) async {
    try {
      var request = supabase
          .from('photographers')
          .select('*, users!inner(*)');
      
      // Поиск по имени
      if (query.isNotEmpty) {
        request = request.or('users.name.ilike.%$query%,users.surname.ilike.%$query%');
      }
      
      // Фильтр по городу
      if (cityId != null) {
        request = request.eq('city_id', cityId);
      }
      
      // Фильтр по цене
      if (minPrice != null) {
        request = request.gte('price', minPrice);
      }
      
      if (maxPrice != null) {
        request = request.lte('price', maxPrice);
      }
      
      final response = await request;
      
      return response.map<Photographer>((json) => Photographer.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при поиске фотографов: $e');
      return [];
    }
  }
}