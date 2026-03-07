import 'package:flutter/material.dart';
import 'package:flyem_app/screens/main_nav_screen.dart';

/// الشاشة الرئيسية بعد الـ Splash - تحتوي على الـ NavBar والشاشات الخمس
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavScreen();
  }
}
