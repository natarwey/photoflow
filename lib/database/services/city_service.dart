import 'package:photoflow/database/models/city.dart';
import 'package:photoflow/main.dart';

class CityService {
  Future<List<City>> getCities() async {
    try {
      final response = await supabase
          .from('city')
          .select()
          .order('title');
      
      return response.map<City>((json) => City.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при получении городов: $e');
      return [];
    }
  }
  
  Future<City?> getCityById(int id) async {
    try {
      final response = await supabase
          .from('city')
          .select()
          .eq('id', id)
          .single();
      
      return City.fromJson(response);
    } catch (e) {
      print('Ошибка при получении города: $e');
      return null;
    }
  }
}