import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photoflow/app_background.dart';
import 'package:photoflow/database/models/city.dart';
import 'package:photoflow/database/services/auth_service.dart';
import 'package:photoflow/database/services/city_service.dart';
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
  CityService cityService = CityService();
  bool isPhotographer = false;
  bool isLoading = false;
  List<City> cities = [];
  City? selectedCity;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final citiesList = await cityService.getCities();
      setState(() {
        cities = citiesList;
        if (cities.isNotEmpty) {
          selectedCity = cities.first;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке городов: $e');
      }
    }
  }

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
        // Основной интерфейс
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                  "PHOTO FLOW",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                  const Text(
                    "Регистрация",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextField(
                      controller: surnameController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: const Color.fromARGB(255, 139, 139, 139),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 139, 139, 139),
                        ),
                        labelText: 'Фамилия',
                        labelStyle: const TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: const Color.fromARGB(255, 139, 139, 139),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 139, 139, 139),
                        ),
                        labelText: 'Имя',
                        labelStyle: const TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: const Color.fromARGB(255, 139, 139, 139),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color.fromARGB(255, 139, 139, 139),
                        ),
                        labelText: 'Почта',
                        labelStyle: const TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
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
                      style: const TextStyle(color: Colors.white),
                      cursorColor: const Color.fromARGB(255, 139, 139, 139),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.password,
                          color: Color.fromARGB(255, 139, 139, 139),
                        ),
                        labelText: 'Пароль',
                        labelStyle: const TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
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
                      style: const TextStyle(color: Colors.white),
                      cursorColor: const Color.fromARGB(255, 139, 139, 139),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.password,
                          color: Color.fromARGB(255, 139, 139, 139),
                        ),
                        labelText: 'Повторный пароль',
                        labelStyle: const TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
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
                        fillColor: MaterialStateProperty.resolveWith<Color>((
                          Set<MaterialState> states,
                        ) {
                          return const Color.fromARGB(255, 139, 139, 139);
                        }),
                        checkColor: Colors.white,
                      ),
                      const Text(
                        "Я фотограф",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (isPhotographer && cities.isNotEmpty) ...[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: DropdownButtonFormField<City>(
                        value: selectedCity,
                        decoration: InputDecoration(
                          labelText: 'Город',
                          labelStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(
                            Icons.location_city,
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 139, 139, 139),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 139, 139, 139),
                            ),
                          ),
                        ),
                        items:
                            cities.map((City city) {
                              return DropdownMenuItem<City>(
                                value: city,
                                child: Text(city.title),
                              );
                            }).toList(),
                        onChanged: (City? newValue) {
                          setState(() {
                            selectedCity = newValue;
                          });
                        },
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (emailController.text.isEmpty ||
                                    passController.text.isEmpty ||
                                    repeatController.text.isEmpty ||
                                    nameController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Поля пустые",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Color.fromARGB(255, 139, 139, 139),
                                    ),
                                  );
                                  return;
                                }

                                if (passController.text !=
                                    repeatController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Пароли не совпадают",
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
                                  // Регистрация пользователя
                                  final result = await authService.signUp(
                                    emailController.text,
                                    passController.text,
                                    nameController.text,
                                    surname: surnameController.text,
                                  );

                                  if (result != null && result['success']) {
                                    final user = result['user'];

                                    // Если пользователь - фотограф, создаем запись в таблице photographers
                                    if (isPhotographer &&
                                        selectedCity != null) {
                                      final success = await authService
                                          .createPhotographerAccount(
                                            user['id'], // Доступ через ['id']
                                            selectedCity!.id,
                                          );

                                      if (!success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Ошибка при создании аккаунта фотографа",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: Color.fromARGB(255, 139, 139, 139),
                                          ),
                                        );
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return;
                                      }
                                    }

                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool('isLoggedIn', true);
                                    await prefs.setBool(
                                      'isPhotographer',
                                      isPhotographer,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Зарегистрирован: ${user['email']}", // Доступ через ['email']
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: const Color(
                                          0xFFFF6B6B,
                                        ),
                                      ),
                                    );

                                    Navigator.popAndPushNamed(context, '/home');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result?['error'] ??
                                              "Ошибка регистрации",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: const Color(
                                          0xFFFF6B6B,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (kDebugMode) {
                                    print('Ошибка при регистрации: $e');
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
                                "Создать аккаунт",
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
                        Navigator.popAndPushNamed(context, '/auth');
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
                        "Аккаунт уже есть",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
