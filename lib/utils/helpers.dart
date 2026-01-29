import 'dart:math' as math;
import 'package:flutter/material.dart';

enum Difficulty {
  easy,
  medium,
  hard,
  expert,
}

extension DifficultyExtension on Difficulty {
  String get name {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
/*************  ✨ Windsurf Command ⭐  *************/
/// Returns the cosine of the given value.
///
/// This is a wrapper around the `dart:math` `cos` function.
///
/// @param value The value to calculate the cosine of.
///
/// @return The cosine of the given value.
/*******  c8e5e13d-6222-4e40-9f37-a62f8b5bae9d  *******/        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  double get speedMultiplier {
    switch (this) {
      case Difficulty.easy:
        return 0.8;
      case Difficulty.medium:
        return 1.0;
      case Difficulty.hard:
        return 1.3;
      case Difficulty.expert:
        return 1.7;
    }
  }

  int get lives {
    switch (this) {
      case Difficulty.easy:
        return 5;
      case Difficulty.medium:
        return 3;
      case Difficulty.hard:
        return 2;
      case Difficulty.expert:
        return 1;
    }
  }
}

class MathHelper {
  static final math.Random _random = math.Random();
  
  static math.Random get random => _random;
  
  static double randomDouble(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }
  
  static int randomInt(int min, int max) {
    return min + _random.nextInt(max - min);
  }
  
  static double sin(double value) {
    return math.sin(value);
  }
  
  static double cos(double value) {
    return math.cos(value);
  }
  
  static Color randomColor() {
    return Color.fromARGB(
      255,
      randomInt(50, 255),
      randomInt(50, 255),
      randomInt(50, 255),
    );
  }
  
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    
    return hslLight.toColor();
  }
  
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    
    return hslDark.toColor();
  }
  
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }
}

class GameHelpers {
  static String getColorName(Color color) {
    final hex = color.value.toRadixString(16).padLeft(8, '0');
    
    // Simple color name mapping
    if (color.red > 200 && color.green < 100 && color.blue < 100) return 'Red';
    if (color.green > 200 && color.red < 100 && color.blue < 100) return 'Green';
    if (color.blue > 200 && color.red < 100 && color.green < 100) return 'Blue';
    if (color.red > 200 && color.green > 200 && color.blue < 100) return 'Yellow';
    if (color.red > 200 && color.blue > 200 && color.green < 100) return 'Purple';
    if (color.red < 100 && color.green > 200 && color.blue > 200) return 'Cyan';
    if (color.red > 200 && color.green > 100 && color.blue < 100) return 'Orange';
    
    return 'Color';
  }
  
  static List<Color> generateAnalogousColors(Color baseColor, int count) {
    final hsl = HSLColor.fromColor(baseColor);
    final hue = hsl.hue;
    final colors = <Color>[];
    
    for (int i = 0; i < count; i++) {
      final newHue = (hue + (i * 30)) % 360;
      final newColor = HSLColor.fromAHSL(
        hsl.alpha,
        newHue,
        hsl.saturation,
        hsl.lightness,
      ).toColor();
      colors.add(newColor);
    }
    
    return colors;
  }
  
  static bool colorsMatch(Color color1, Color color2, {double tolerance = 0.1}) {
    final hsl1 = HSLColor.fromColor(color1);
    final hsl2 = HSLColor.fromColor(color2);
    
    final hueDiff = (hsl1.hue - hsl2.hue).abs();
    final satDiff = (hsl1.saturation - hsl2.saturation).abs();
    final lightDiff = (hsl1.lightness - hsl2.lightness).abs();
    
    return hueDiff < 30 && satDiff < tolerance && lightDiff < tolerance;
  }
  
  static String getDifficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '😊';
      case Difficulty.medium:
        return '😐';
      case Difficulty.hard:
        return '😅';
      case Difficulty.expert:
        return '🤯';
    }
  }
  
  static String getAnimalEmoji(String animalName) {
    switch (animalName.toLowerCase()) {
      case 'monkey':
        return '🐒';
      case 'elephant':
        return '🐘';
      case 'giraffe':
        return '🦒';
      case 'lion':
        return '🦁';
      case 'tiger':
        return '🐅';
      case 'panda':
        return '🐼';
      default:
        return '🐾';
    }
  }
}