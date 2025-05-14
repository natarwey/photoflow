import 'package:photoflow/database/models/genre.dart';
import 'package:photoflow/main.dart';

class GenreService {
  Future<List<Genre>> getGenres() async {
    try {
      final response = await supabase
          .from('genres')
          .select()
          .order('title');
      
      return response.map<Genre>((json) => Genre.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при получении жанров: $e');
      return [];
    }
  }
  
  Future<Genre?> getGenreById(int id) async {
    try {
      final response = await supabase
          .from('genres')
          .select()
          .eq('id', id)
          .single();
      
      return Genre.fromJson(response);
    } catch (e) {
      print('Ошибка при получении жанра: $e');
      return null;
    }
  }
}