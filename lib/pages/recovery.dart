import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoflow/app_background.dart';
import 'package:photoflow/database/services/auth_service.dart';

class RecoveryPage extends StatelessWidget {
  const RecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    AuthService authService = AuthService();
    return AppBackground(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: const Text(
            "Восстановление пароля", 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            onPressed: (){
              Navigator.popAndPushNamed(context, '/auth');
            }, 
            icon: const Icon(
              CupertinoIcons.back,
              color: Colors.black,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextField(
                  controller: emailController,
                  cursorColor: const Color.fromARGB(255, 139, 139, 139),
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color.fromARGB(255, 139, 139, 139),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () async {
                        if (emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Поле пустое",
                                style: TextStyle(color: Colors.black),
                              ),
                              backgroundColor: Color.fromARGB(255, 139, 139, 139),
                            ),
                          );
                        } else {
                          await authService.recoveryPassword(emailController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Письмо для восстановления отправлено",
                                style: TextStyle(color: Colors.black),
                              ),
                              backgroundColor: Color.fromARGB(255, 139, 139, 139),
                            ),
                          );
                          emailController.clear();
                        }
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Color.fromARGB(255, 139, 139, 139),
                      ),
                    ),
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.black),
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Для восстановления доступа к своему аккаунту пожалуйста введите свою почту",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}