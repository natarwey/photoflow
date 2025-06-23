import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  final supabase = Supabase.instance.client;

  // Проверяет, находится ли фото в избранном у текущего пользователя
  Future<bool> isFavorited(int portfolioItemId) async {
    final userId = supabase.auth.currentUser!.id;
    final result = await supabase
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('portfolio_item_id', portfolioItemId)
        .limit(1);

    return result.isNotEmpty;
  }

  // Добавляет фото в избранное
  Future<void> addToFavorites(int portfolioItemId) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('favorites').insert({
      'user_id': userId,
      'portfolio_item_id': portfolioItemId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Удаляет фото из избранного
  Future<void> removeFromFavorites(int portfolioItemId) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('portfolio_item_id', portfolioItemId);
  }

  // Получает все избранные фото пользователя
  Future<List<Map<String, dynamic>>> getFavoritePhotos() async {
    final userId = supabase.auth.currentUser!.id;
    final result = await supabase
        .from('favorites')
        .select('portfolio_item_id, portfolio_items(*)')
        .eq('user_id', userId);

    return result.map((item) => item as Map<String, dynamic>).toList();
  }
}