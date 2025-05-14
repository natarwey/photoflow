import 'package:photoflow/database/models/location.dart';
import 'package:photoflow/main.dart';

class LocationService {
  Future<List<Location>> getLocations() async {
    try {
      final response = await supabase
          .from('location')
          .select()
          .order('title');
      
      return response.map<Location>((json) => Location.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при получении локаций: $e');
      return [];
    }
  }
  
  Future<Location?> getLocationById(int id) async {
    try {
      final response = await supabase
          .from('location')
          .select()
          .eq('id', id)
          .single();
      
      return Location.fromJson(response);
    } catch (e) {
      print('Ошибка при получении локации: $e');
      return null;
    }
  }
}