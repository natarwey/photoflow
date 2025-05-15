import 'package:flutter/foundation.dart';
import 'package:photoflow/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Вход пользователя
  Future<User?> signIn(String email, String password) async {
    try {
      // Аутентификация пользователя
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Если аутентификация прошла успешно, возвращаем пользователя
      if (response.user != null) {
        return response.user;
      }
      
      if (kDebugMode) {
        print('Пользователь не найден в системе аутентификации');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка входа: $e');
      }
      return null;
    }
  }

  // Регистрация пользователя
  Future<User?> signUp(String email, String password, String name, {String? surname}) async {
    try {
      // Регистрация пользователя в системе аутентификации Supabase
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        return null;
      }
      
      // Добавляем пользователя в таблицу users
      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'name': name,
        'surname': surname,
        'password': password,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      if (kDebugMode) {
        print('Пользователь успешно добавлен в таблицу users');
      }
      
      return response.user;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка регистрации: $e');
      }
      // Если произошла ошибка, пытаемся выйти из системы, чтобы не оставлять "висящую" аутентификацию
      try {
        await supabase.auth.signOut();
      } catch (_) {}
      return null;
    }
  }
  
  // Создание аккаунта фотографа
  Future<bool> createPhotographerAccount(String userId, int cityId, {String? bio, int? experience, int price = 0, String? socialLinks}) async {
    try {
      // Проверяем, существует ли уже аккаунт фотографа для этого пользователя
      final existingPhotographer = await supabase
          .from('photographers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existingPhotographer != null) {
        if (kDebugMode) {
          print('Аккаунт фотографа уже существует');
        }
        return true; // Аккаунт уже существует, считаем это успехом
      }
      
      // Создаем аккаунт фотографа
      await supabase.from('photographers').insert({
        'user_id': userId,
        'city_id': cityId,
        'bio': bio,
        'experience': experience,
        'price': price,
        'social_links': socialLinks,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      if (kDebugMode) {
        print('Аккаунт фотографа успешно создан');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка создания аккаунта фотографа: $e');
      }
      return false;
    }
  }

  Future<void> recoveryPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      if (kDebugMode) {
        print('Письмо для восстановления отправлено на $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка восстановления пароля: $e');
      }
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}