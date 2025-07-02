import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photoflow/app_background.dart';
import 'package:photoflow/database/services/auth_service.dart';
import 'package:photoflow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  AuthService authService = AuthService();
  bool isLoading = false;
  bool _isPhotographer = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Фоновое изображение
        SizedBox.expand(
          child: Image.asset('images/background.jpg', fit: BoxFit.cover),
        ),
        // Затемняющий слой
        SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
            ),
          ),
        ),
        // Основной контент (Scaffold)
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "PHOTO FLOW",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Вход",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: TextField(
                    controller: emailController,
                    cursorColor: const Color.fromARGB(255, 139, 139, 139),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Color.fromARGB(255, 139, 139, 139),
                      ),
                      labelText: 'Почта',
                      labelStyle: const TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 139, 139, 139)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 139, 139, 139)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: TextField(
                    controller: passController,
                    obscureText: true,
                    cursorColor: const Color.fromARGB(255, 139, 139, 139),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.password,
                        color: Color.fromARGB(255, 139, 139, 139),
                      ),
                      labelText: 'Пароль',
                      labelStyle: const TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 139, 139, 139)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 139, 139, 139)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    child: const Text(
                      "Забыли пароль?",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, '/recovery');
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              if (emailController.text.isEmpty ||
                                  passController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Поля пустые!",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Color.fromARGB(255, 139, 139, 139),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                isLoading = true;
                              });

                              try {
                                final result = await authService.signIn(
                                  emailController.text,
                                  passController.text,
                                );
                                if (result != null && result['success']) {
                                  final user = result['user'];
                                  final bool isPhotographer =
                                      result['isPhotographer'];

                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool('isLoggedIn', true);
                                  await prefs.setBool(
                                    'isPhotographer',
                                    isPhotographer,
                                  );

                                  if (kDebugMode) {
                                    print(
                                      'Успешный вход: ${user['email']} как ${isPhotographer ? 'фотограф' : 'клиент'}',
                                    );
                                  }

                                  Navigator.popAndPushNamed(context, '/home');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Неверный email или пароль",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Color.fromARGB(255, 139, 139, 139),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (kDebugMode) {
                                  print('Ошибка при входе: $e');
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Ошибка: $e",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: const Color.fromARGB(255, 139, 139, 139),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 139, 139, 139),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              "Войти",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.popAndPushNamed(context, '/reg');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color.fromARGB(255, 139, 139, 139),
                        width: 2,
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Создать аккаунт",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
