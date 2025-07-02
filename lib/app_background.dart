import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const AppBackground({super.key, required this.child, required this.backgroundColor,});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: child,
    );
  }
}