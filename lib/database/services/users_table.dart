import 'package:photoflow/main.dart';

class UsersTable {
  Future<void> addUser(String name, String email, String password, {String surname = '', String avatarUrl = ''}) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      
      await supabase.from('users').insert({
        'id': userId,
        'name': name,
        'surname': surname,
        'email': email,
        'password': password,
        'avatar_url': avatarUrl,
      });
      
      print('Пользователь добавлен в базу данных');
    } catch (e) {
      print('Ошибка добавления пользователя: $e');
    }
  }
}