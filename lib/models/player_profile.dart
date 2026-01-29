class PlayerProfile {
  String name;
  int age;
  String favoriteColor;
  int gamesPlayed;
  int totalScore;
  List<String> achievements;
  bool soundEnabled;
  bool vibrationEnabled;
  bool colorblindMode;
  Difficulty difficulty;

  PlayerProfile({
    this.name = 'Carnival Player',
    this.age = 5,
    this.favoriteColor = 'red',
    this.gamesPlayed = 0,
    this.totalScore = 0,
    List<String>? achievements,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.colorblindMode = false,
    this.difficulty = Difficulty.easy,
  }) : achievements = achievements ?? [];

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      name: json['name'] ?? 'Carnival Player',
      age: json['age'] ?? 5,
      favoriteColor: json['favoriteColor'] ?? 'red',
      gamesPlayed: json['gamesPlayed'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      achievements: List<String>.from(json['achievements'] ?? []),
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      colorblindMode: json['colorblindMode'] ?? false,
      difficulty: Difficulty.values[json['difficulty'] ?? 0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'favoriteColor': favoriteColor,
      'gamesPlayed': gamesPlayed,
      'totalScore': totalScore,
      'achievements': achievements,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'colorblindMode': colorblindMode,
      'difficulty': difficulty.index,
    };
  }

  void addAchievement(String achievement) {
    if (!achievements.contains(achievement)) {
      achievements.add(achievement);
    }
  }

  bool hasAchievement(String achievement) {
    return achievements.contains(achievement);
  }

  List<String> getAvailableAchievements() {
    return [
      'First Catch',
      'Score 100',
      'Score 500',
      'Perfect Combo 10',
      'Color Master',
      'Speed Demon',
      'Animal Lover',
    ];
  }
}

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
        return 'Hard';
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