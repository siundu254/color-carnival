class GameData {
  int score;
  int highScore;
  int level;
  int lives;
  int combo;
  int totalCatches;
  List<String> unlockedAnimals;
  Map<String, int> colorStats;
  DateTime? lastPlayed;

  GameData({
    this.score = 0,
    this.highScore = 0,
    this.level = 1,
    this.lives = 3,
    this.combo = 0,
    this.totalCatches = 0,
    List<String>? unlockedAnimals,
    Map<String, int>? colorStats,
    this.lastPlayed,
  })  : unlockedAnimals = unlockedAnimals ?? ['monkey'],
        colorStats = colorStats ?? {
          'red': 0,
          'teal': 0,
          'yellow': 0,
          'green': 0,
          'blue': 0,
          'purple': 0,
        };

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      score: json['score'] ?? 0,
      highScore: json['highScore'] ?? 0,
      level: json['level'] ?? 1,
      lives: json['lives'] ?? 3,
      combo: json['combo'] ?? 0,
      totalCatches: json['totalCatches'] ?? 0,
      unlockedAnimals: List<String>.from(json['unlockedAnimals'] ?? ['monkey']),
      colorStats: Map<String, int>.from(json['colorStats'] ?? {
        'red': 0,
        'teal': 0,
        'yellow': 0,
        'green': 0,
        'blue': 0,
        'purple': 0,
      }),
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'highScore': highScore,
      'level': level,
      'lives': lives,
      'combo': combo,
      'totalCatches': totalCatches,
      'unlockedAnimals': unlockedAnimals,
      'colorStats': colorStats,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }

  void resetGame() {
    score = 0;
    lives = 3;
    combo = 0;
    lastPlayed = DateTime.now();
  }

  void addScore(int points) {
    score += points;
    if (score > highScore) {
      highScore = score;
    }
  }

  void incrementCatches(String colorName) {
    totalCatches++;
    if (colorStats.containsKey(colorName)) {
      colorStats[colorName] = (colorStats[colorName] ?? 0) + 1;
    }
  }

  bool canUnlockAnimal() {
    return score >= (unlockedAnimals.length * 1000);
  }

  void unlockAnimal(String animal) {
    if (!unlockedAnimals.contains(animal)) {
      unlockedAnimals.add(animal);
    }
  }
}