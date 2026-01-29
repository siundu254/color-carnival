import 'package:flutter/material.dart';

class GameConstants {
  static const String gameTitle = 'Color Catch Carnival';
  static const String gameVersion = '1.0.0';
  
  // Screen dimensions
  static late double screenWidth;
  static late double screenHeight;
  
  // Colors for the game
  static const List<Color> ballColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFD166), // Yellow
    Color(0xFF06D6A0), // Green
    Color(0xFF118AB2), // Blue
    Color(0xFF9D4EDD), // Purple
  ];
  
  static const List<String> colorNames = [
    'Red', 'Teal', 'Yellow', 'Green', 'Blue', 'Purple'
  ];
  
  // Game settings
  static const double initialSpeed = 2.0;
  static const int startingLives = 3;
  static const int pointsPerCatch = 10;
  static const int comboBonus = 5;
  
  // Assets paths
  static const String backgroundImage = 'images/carnival_bg.png';
  static const String bucketImage = 'images/bucket.png';
  static const List<String> animalImages = [
    'animals/monkey.png',
    'animals/elephant.png',
    'animals/giraffe.png',
  ];
  
  // Sound paths
  static const String catchSound = 'sounds/catch.mp3';
  static const String missSound = 'sounds/miss.mp3';
  static const String levelUpSound = 'sounds/level_up.mp3';
}