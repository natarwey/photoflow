import 'package:flutter/material.dart';
import 'package:photoflow/app_background.dart';
import 'package:photoflow/database/services/auth_service.dart';
import 'package:photoflow/database/services/users_table.dart';
import 'package:photoflow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  TextEditingController surnameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController repeatController = TextEditingController();
  AuthService authService = AuthService();
  UsersTable usersTable = UsersTable();
  bool isPhotographer = false;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset('images/logo.png'),
                const Text(
                  "Регистрация",
                  style: TextStyle(
                    fontSize: 30, 
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: TextField(
                    controller: surnameController,
                    style: const TextStyle(color: Colors.black),
                    cursorColor: const Color(0xFFFFD700),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Color(0xFFFFD700)),
                      labelText: 'Фамилия',
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.black),
                    cursorColor: const Color(0xFFFFD700),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Color(0xFFFFD700)),
                      labelText: 'Имя',
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.black),
                    cursorColor: const Color(0xFFFFD700),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: Color(0xFFFFD700)),
                      labelText: 'Почта',
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
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
                    style: const TextStyle(color: Colors.black),
                    cursorColor: const Color(0xFFFFD700),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.password, color: Color(0xFFFFD700)),
                      labelText: 'Пароль',
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: TextField(
                    controller: repeatController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black),
                    cursorColor: const Color(0xFFFFD700),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.password, color: Color(0xFFFFD700)),
                      labelText: 'Повторный пароль',
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isPhotographer,
                      onChanged: (value) {
                        setState(() {
                          isPhotographer = value ?? false;
                        });
                      },
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return const Color(0xFFFFD700);
                        },
                      ),
                      checkColor: Colors.black,
                    ),
                    const Text(
                      "Я фотограф",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (emailController.text.isEmpty ||
                          passController.text.isEmpty ||
                          repeatController.text.isEmpty ||
                          nameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Поля пустые",
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Color(0xFFFFD700),
                          ),
                        );
                      } else {
                        if (passController.text == repeatController.text) {
                          var user = await authService.signUp(
                            emailController.text, passController.text);
                          if (user != null) {
                            await usersTable.addUser(
                              nameController.text, 
                              emailController.text, 
                              passController.text,
                              surname: surnameController.text,
                            );
                            
                            // Если пользователь - фотограф, создаем запись в таблице photographers
                            if (isPhotographer) {
                              await supabase.from('photographers').insert({
                                'user_id': user.id,
                              });
                            }
                            
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('isLoggedIn', true);
                            await prefs.setBool('isPhotographer', isPhotographer);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Зарегистрирован: ${user.email!}",
                                  style: const TextStyle(color: Colors.black),
                                ),
                                backgroundColor: const Color(0xFFFFD700),
                              ),
                            );
                            Navigator.popAndPushNamed(context, '/home');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Пользователь не создан",
                                  style: TextStyle(color: Colors.black),
                                ),
                                backgroundColor: Color(0xFFFFD700),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Пароли не совпадают",
                                style: TextStyle(color: Colors.black),
                              ),
                              backgroundColor: Color(0xFFFFD700),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Создать аккаунт",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.popAndPushNamed(context, '/auth');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFFD700), width: 2),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Аккаунт уже есть",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}