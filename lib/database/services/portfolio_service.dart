import 'package:photoflow/database/models/portfolio_item.dart';
import 'package:photoflow/main.dart';

class PortfolioService {
  Future<PortfolioItem> getRandomPortfolioItem() async {
    try {
      final response = await supabase
          .from('portfolio_items')
          .select('*, moods:mood_id(title)')
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
  
  Future<List<PortfolioItem>> getPortfolioByPhotographer(int photographerId) async {
    try {
      final response = await supabase
          .from('portfolio_items')
          .select('*, moods:mood_id(title)')
          .eq('photographer_id', photographerId)
          .order('created_at', ascending: false);
      
      return response.map<PortfolioItem>((json) => PortfolioItem.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при получении портфолио фотографа: $e');
      return [];
    }
  }
}