import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  final supabase = Supabase.instance.client;

  // Добавляет фото в избранное
  Future<void> addToFavorites(int portfolioItemId) async {
    await supabase.from('favorites').insert({
      'portfolio_item_id': portfolioItemId,
    });
  }

  // Удаляет фото из избранного
  Future<void> removeFromFavorites(int portfolioItemId) async {
    await supabase
        .from('favorites')
        .delete()
        .eq('portfolio_item_id', portfolioItemId);
  }

  // Получает все избранные фото пользователя
  Future<List<Map<String, dynamic>>> getFavoritePhotos() async {
    final result = await supabase
        .from('favorites')
        .select('portfolio_item_id, portfolio_items(*)');
    return result.map((item) => item as Map<String, dynamic>).toList();
  }
}
