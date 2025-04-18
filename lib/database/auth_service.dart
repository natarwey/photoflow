import 'package:photoflow/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  Future<User?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      print('Ошибка входа: $e');
      return null;
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      print('Ошибка регистрации: $e');
      return null;
    }
  }

  Future<void> recoveryPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      print('Письмо для восстановления отправлено на $email');
    } catch (e) {
      print('Ошибка восстановления пароля: $e');
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}