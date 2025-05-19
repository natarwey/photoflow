import 'package:flutter/foundation.dart';
import 'package:photoflow/database/models/user.dart';
import 'package:photoflow/main.dart';

class UserService {
  // Получение текущего пользователя
  Future<User?> getCurrentUser() async {
    try {
      // Получаем текущего пользователя из Supabase Auth
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        return null;
      }
      
      // Получаем данные пользователя из таблицы users
      final userData = await supabase
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .single();
      
      return User.fromJson(userData);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении текущего пользователя: $e');
      }
      return null;
    }
  }
  
  // Получение пользователя по ID
  Future<User?> getUserById(String userId) async {
    try {
      final userData = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return User.fromJson(userData);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении пользователя по ID: $e');
      }
      return null;
    }
  }
  
  // Обновление данных пользователя
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await supabase
          .from('users')
          .update(data)
          .eq('id', userId);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при обновлении пользователя: $e');
      }
      return false;
    }
  }
}