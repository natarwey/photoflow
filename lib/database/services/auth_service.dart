import 'package:flutter/foundation.dart';
import 'package:photoflow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Вход пользователя
  Future<Map<String, dynamic>?> signIn(String email, String password, {bool isPhotographer = false}) async {
  try {
    // Получаем пользователя из таблицы users
    final userData = await supabase
        .from('users')
        .select()
        .eq('email', email)
        .eq('password', password)
        .maybeSingle();

    if (userData == null) {
      return null; // Неверные учетные данные
    }

    bool userIsPhotographer = false;

    if (isPhotographer) {
      // Проверяем, есть ли запись в таблице photographers
      final photographerData = await supabase
          .from('photographers')
          .select()
          .eq('user_id', userData['id'])
          .maybeSingle();

      if (photographerData == null) {
        // У пользователя нет аккаунта фотографа
        return {'success': false, 'error': 'Вы выбрали "Фотограф", но у вас нет аккаунта фотографа'};
      }

      userIsPhotographer = true;
    }

    // Сохраняем данные в SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userData['id']);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isPhotographer', userIsPhotographer);

    return {
      'success': true,
      'user': userData,
      'isPhotographer': userIsPhotographer,
    };
  } catch (e) {
    if (kDebugMode) {
      print('Ошибка при входе: $e');
    }
    return {'success': false, 'error': e.toString()};
  }
}

  // Регистрация пользователя
  Future<Map<String, dynamic>?> signUp(String email, String password, String name, {String? surname}) async {
  try {
    // Регистрация пользователя в системе аутентификации SupabaseAdd commentMore actions
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

    if (authResponse.user == null) {
      return {'success': false, 'error': 'Ошибка аутентификации'};
    }

    // 2. Добавляем пользователя в таблицу users
    final userData = {
      'id': authResponse.user!.id,
      'email': email,
      'name': name,
      'surname': surname,
      'password': password, // Обратите внимание: хранение пароля в открытом виде небезопасно
      'created_at': DateTime.now().toIso8601String(),
    };

    final insertResponse = await supabase
        .from('users')
        .insert(userData)
        .select()
        .single();

    if (kDebugMode) {
      print('Пользователь успешно добавлен в таблицу users');
    }

    // 3. Сохраняем данные в SharedPreferences (важная часть, которую вы просили не убирать)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', authResponse.user!.id);
    await prefs.setBool('isLoggedIn', true);

    return {
      'success': true,
      'user': insertResponse, // Возвращаем данные из таблицы users
    };
    } catch (e) {
    if (kDebugMode) {
      print('Ошибка регистрации: $e');
    }
    
    // При ошибке пытаемся выйти из системы
    try {
      await supabase.auth.signOut();
    } catch (_) {}
    
    return {
      'success': false,
      'error': e.toString(),
    };
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