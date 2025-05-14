import 'package:flutter/material.dart';

class PhotographerProfilePage extends StatelessWidget {
  const PhotographerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем ID фотографа из аргументов
    final photographerId = ModalRoute.of(context)!.settings.arguments as int;
    
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD700),
        title: const Text(
          'Профиль фотографа',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Text(
          'Профиль фотографа ID: $photographerId\nБудет реализован позже',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}