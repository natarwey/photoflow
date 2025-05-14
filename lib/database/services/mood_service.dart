import 'package:photoflow/database/models/mood.dart';
import 'package:photoflow/main.dart';

class MoodService {
  Future<List<Mood>> getMoods() async {
    try {
      final response = await supabase
          .from('mood')
          .select()
          .order('title');
      
      return response.map<Mood>((json) => Mood.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при получении настроений: $e');
      return [];
    }
  }
  
  Future<Mood?> getMoodById(int id) async {
    try {
      final response = await supabase
          .from('mood')
          .select()
          .eq('id', id)
          .single();
      
      return Mood.fromJson(response);
    } catch (e) {
      print('Ошибка при получении настроения: $e');
      return null;
    }
  }
}