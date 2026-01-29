import 'package:shared_preferences/shared_preferences.dart';
import 'helpers.dart';

class DataPersistenceService {
  static const String _highScoreKey = 'high_score';
  static const String _userNameKey = 'user_name';
  static const String _userAgeKey = 'user_age';
  static const String _unlockedLevelsKey = 'unlocked_levels';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _colorblindModeKey = 'colorblind_mode';
  static const String _difficultyKey = 'difficulty';
  static const String _favoriteColorKey = 'favorite_color';
  static const String _completedLevelsKey = 'completed_levels';

  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }

  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Super Player';
  }

  static Future<void> saveUserAge(int age) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userAgeKey, age);
  }

  static Future<int> getUserAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userAgeKey) ?? 5;
  }

  static Future<void> saveUnlockedLevels(int levels) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unlockedLevelsKey, levels);
  }

  static Future<int> getUnlockedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_unlockedLevelsKey) ?? 1;
  }

  static Future<void> saveSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  static Future<void> saveMusicEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicEnabledKey, enabled);
  }

  static Future<bool> getMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_musicEnabledKey) ?? true;
  }

  static Future<void> saveVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, enabled);
  }

  static Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  static Future<void> saveColorblindMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_colorblindModeKey, enabled);
  }

  static Future<bool> getColorblindMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_colorblindModeKey) ?? false;
  }

  static Future<void> saveDifficulty(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    // Save difficulty by index
    await prefs.setInt(_difficultyKey, difficulty.index);
  }

  static Future<Difficulty> getDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_difficultyKey) ?? 0;
    // Get difficulty by index, default to easy
    return Difficulty.values[index.clamp(0, Difficulty.values.length - 1)];
  }

  static Future<void> saveFavoriteColor(String color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoriteColorKey, color);
  }

  static Future<String> getFavoriteColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_favoriteColorKey) ?? 'Blue';
  }

  static Future<void> markLevelCompleted(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final completedLevels = await getCompletedLevels();
    if (!completedLevels.contains(level)) {
      completedLevels.add(level);
      await prefs.setStringList(_completedLevelsKey, 
          completedLevels.map((l) => l.toString()).toList());
    }
  }

  static Future<List<int>> getCompletedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final levelStrings = prefs.getStringList(_completedLevelsKey) ?? [];
    return levelStrings.map((str) => int.tryParse(str) ?? 0).where((l) => l > 0).toList();
  }

  static Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}