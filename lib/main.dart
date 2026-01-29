import 'package:flutter/material.dart';
import 'package:color_carnival/screens/home_screen.dart';
import 'package:color_carnival/utils/constants.dart';

void main() {
  runApp(const ColorCatchCarnival());
}

class ColorCatchCarnival extends StatelessWidget {
  const ColorCatchCarnival({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Carnival',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'ComicNeue', // Kid-friendly font
        scaffoldBackgroundColor: const Color(0xFFFEF9FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A67CE),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}