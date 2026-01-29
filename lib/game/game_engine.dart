import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/data_persistence_service.dart';
import '../utils/helpers.dart';

// Ball class moved to top level
class GameBall {
  Color color;
  double x; // 0.0 to 1.0
  double y; // 0.0 to 1.0
  double speed;
  double size;
  bool isPowerUp;
  String powerUpType;
  bool isCaught = false;
  int id; // Unique ID for each ball
  
  GameBall({
    required this.id,
    required this.color,
    required this.x,
    required this.y,
    required this.speed,
    this.size = 0.1,
    this.isPowerUp = false,
    this.powerUpType = '',
  });
}

class GameEngine {
  // Game state
  int score = 0;
  int highScore = 0;
  int level = 1;
  int lives = 3;
  int combo = 0;
  int maxCombo = 0;
  bool isGameOver = false;
  bool isPaused = false;
  bool isLevelComplete = false; // NEW: Track level completion
  
  // Level progression
  int ballsCaughtInLevel = 0; // NEW: Track balls caught in current level
  int ballsRequiredForNextLevel = 10; // NEW: Balls needed to advance
  
  // MATCH VISUAL CATCHER DIMENSIONS
  double bucketPosition = 0.5;
  final double bucketWidth = 0.5;
  final double bucketHeight = 0.094;
  
  // Colors
  static const List<Color> ballColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFD166), // Yellow
    Color(0xFF06D6A0), // Green
    Color(0xFF118AB2), // Blue
    Color(0xFF9D4EDD), // Purple
  ];
  
  List<GameBall> balls = [];
  Random random = Random();
  DateTime? lastBallSpawn;
  double ballSpawnInterval = 1000; // milliseconds
  
  // Difficulty settings
  Difficulty _difficulty = Difficulty.easy;
  double _speedMultiplier = 1.0;
  
  // Game balance
  final double _minBallSpacing = 0.15; // Minimum space between balls
  
  // Ball ID counter
  int _ballIdCounter = 0;
  
  // Catch zone visualization
  List<GameBall> ballsInCatchZone = [];
  List<GameBall> ballsInPerfectZone = [];
  
  // Screen dimensions reference (will be updated from PlayScreen)
  double _screenWidth = 400; // Default, will be updated
  double _screenHeight = 800; // Default, will be updated
  
  // Initialize game
  Future<void> startNewGame() async {
    score = 0;
    level = 1;
    ballsCaughtInLevel = 0;
    ballsRequiredForNextLevel = _calculateBallsRequiredForLevel(1);
    combo = 0;
    maxCombo = 0;
    isGameOver = false;
    isPaused = false;
    isLevelComplete = false;
    balls.clear();
    ballsInCatchZone.clear();
    ballsInPerfectZone.clear();
    _ballIdCounter = 0;
    ballSpawnInterval = 1500; // Start slower
    bucketPosition = 0.5;
    lastBallSpawn = DateTime.now();
    
    // Load difficulty and high score
    await _loadGameSettings();
  }
  
  // Start specific level
  Future<void> startLevel(int newLevel) async {
    level = newLevel;
    ballsCaughtInLevel = 0;
    ballsRequiredForNextLevel = _calculateBallsRequiredForLevel(level);
    combo = 0;
    maxCombo = 0;
    isGameOver = false;
    isPaused = false;
    isLevelComplete = false;
    balls.clear();
    ballsInCatchZone.clear();
    ballsInPerfectZone.clear();
    _ballIdCounter = 0;
    ballSpawnInterval = 1500 - (level * 100).clamp(0.0, 1000.0); // Faster spawn at higher levels
    bucketPosition = 0.5;
    lastBallSpawn = DateTime.now();
    
    // Load difficulty and high score
    await _loadGameSettings();
  }
  
  // Calculate balls required for each level
  int _calculateBallsRequiredForLevel(int levelNum) {
    // Level 1: 10 balls, Level 2: 15 balls, Level 3: 20 balls, etc.
    return 10 + ((levelNum - 1) * 5);
  }
  
  // Update screen dimensions from PlayScreen
  void updateScreenDimensions(double width, double height) {
    _screenWidth = width;
    _screenHeight = height;
  }
  
  // Load game settings from persistence
  Future<void> _loadGameSettings() async {
    _difficulty = await DataPersistenceService.getDifficulty();
    _speedMultiplier = _difficulty.speedMultiplier;
    lives = _difficulty.lives;
    highScore = await DataPersistenceService.getHighScore();
  }
  
  // ENHANCED: Robust collision detection matching visual catcher
  Map<String, bool> checkBallCollision(GameBall ball) {
    // Validate inputs
    if (ball.x.isNaN || ball.y.isNaN || ball.size.isNaN) {
      return {'inBucket': false, 'inCatchZone': false, 'inPerfectZone': false};
    }
    
    // Convert ball position to screen coordinates
    final ballScreenX = ball.x * _screenWidth;
    final ballScreenY = ball.y * _screenHeight;
    final ballDiameter = ball.size * min(_screenWidth, _screenHeight);
    
    // Catcher position in screen coordinates
    final catcherLeft = bucketPosition * _screenWidth - (_screenWidth * bucketWidth / 2);
    final catcherRight = catcherLeft + (_screenWidth * bucketWidth);
    final catcherTop = _screenHeight - (_screenHeight * bucketHeight) - 160; // 160px from bottom
    final catcherBottom = catcherTop + (_screenHeight * bucketHeight);
    final catcherCenter = catcherLeft + (_screenWidth * bucketWidth / 2);
    
    // Ball center coordinates
    final ballCenterX = ballScreenX;
    final ballCenterY = ballScreenY + ballDiameter / 2;
    
    // Define zones
    final perfectZoneLeft = catcherCenter - (_screenWidth * bucketWidth * 0.3 / 2);
    final perfectZoneRight = catcherCenter + (_screenWidth * bucketWidth * 0.3 / 2);
    final perfectZoneTop = catcherTop - 10; // 10px grace above
    final perfectZoneBottom = catcherBottom + 10; // 10px grace below
    
    final catchZoneLeft = catcherLeft - 20; // 20px extended catch zone
    final catchZoneRight = catcherRight + 20; // 20px extended catch zone
    final catchZoneTop = catcherTop - 30; // 30px grace above catcher
    final catchZoneBottom = catcherBottom + 20; // 20px grace below catcher
    
    // Check zones
    final inHorizontalCatchZone = ballCenterX > catchZoneLeft && ballCenterX < catchZoneRight;
    final inVerticalCatchZone = ballCenterY > catchZoneTop && ballCenterY < catchZoneBottom;
    final inCatchZone = inHorizontalCatchZone && inVerticalCatchZone;
    
    final inHorizontalPerfectZone = ballCenterX > perfectZoneLeft && ballCenterX < perfectZoneRight;
    final inVerticalPerfectZone = ballCenterY > perfectZoneTop && ballCenterY < perfectZoneBottom;
    final inPerfectZone = inHorizontalPerfectZone && inVerticalPerfectZone;
    
    // In bucket (strict check - must be within visual bounds)
    final inHorizontalBucket = ballCenterX > catcherLeft && ballCenterX < catcherRight;
    final inVerticalBucket = ballCenterY > catcherTop && ballCenterY < catcherBottom;
    final inBucket = inHorizontalBucket && inVerticalBucket;
    
    return {
      'inBucket': inBucket,
      'inCatchZone': inCatchZone,
      'inPerfectZone': inPerfectZone,
    };
  }
  
  // Check if ball is in bucket for scoring
  bool isBallInBucket(GameBall ball) {
    return checkBallCollision(ball)['inBucket'] ?? false;
  }
  
  // Get catch quality for visual feedback and scoring
  Map<String, double> getCatchDetails(GameBall ball) {
    final collisions = checkBallCollision(ball);
    
    if (!collisions['inBucket']! && !collisions['inCatchZone']!) {
      return {'quality': 0.0, 'scoreMultiplier': 0.0, 'zone': 0.0};
    }
    
    // Convert ball position to screen coordinates
    final ballScreenX = ball.x * _screenWidth;
    
    // Catcher position in screen coordinates
    final catcherLeft = bucketPosition * _screenWidth - (_screenWidth * bucketWidth / 2);
    final catcherRight = catcherLeft + (_screenWidth * bucketWidth);
    final catcherCenter = catcherLeft + (_screenWidth * bucketWidth / 2);
    
    // Calculate distance from center (normalized 0-1)
    final distanceFromCenter = (ballScreenX - catcherCenter).abs();
    final maxDistance = (_screenWidth * bucketWidth) / 2;
    final normalizedDistance = maxDistance > 0 ? distanceFromCenter / maxDistance : 0.0;
    
    // Base quality
    double quality = 1.0 - normalizedDistance.clamp(0.0, 1.0);
    
    // Bonus for perfect zone
    if (collisions['inPerfectZone']!) {
      quality *= 1.5; // 50% bonus
    }
    
    // Score multiplier based on quality
    double scoreMultiplier = 0.8 + (quality * 0.6); // 0.8x to 1.4x
    
    // Zone value for visual feedback (0=catch zone edge, 1=perfect center)
    double zoneValue = 1.0 - normalizedDistance;
    
    return {
      'quality': quality.clamp(0.0, 1.5),
      'scoreMultiplier': scoreMultiplier.clamp(0.8, 1.4),
      'zone': zoneValue.clamp(0.0, 1.0),
    };
  }
  
  // Update game state
  void update(double deltaTime) {
    // Safety checks: stop if game over, paused, or invalid deltaTime
    if (isGameOver || isPaused || isLevelComplete) return;
    
    // Validate deltaTime
    if (deltaTime.isNaN || deltaTime.isInfinite || deltaTime <= 0) {
      deltaTime = 0.016; // Default to 60 FPS
    }
    
    // Ensure deltaTime is within reasonable bounds
    final safeDeltaTime = deltaTime.clamp(0.001, 0.1);
    
    // Clear catch zone lists
    ballsInCatchZone.clear();
    ballsInPerfectZone.clear();
    
    // Process existing balls
    final ballsToRemove = <GameBall>[];
    
    for (var ball in balls) {
      // Skip caught balls
      if (ball.isCaught) {
        ballsToRemove.add(ball);
        continue;
      }
      
      // Validate ball properties
      if (ball.x.isNaN || ball.x.isInfinite) ball.x = 0.5;
      if (ball.y.isNaN || ball.y.isInfinite) ball.y = -0.1;
      if (ball.speed.isNaN || ball.speed.isInfinite) ball.speed = 0.2;
      if (ball.size.isNaN || ball.size.isInfinite) ball.size = 0.1;
      
      // Update ball position with difficulty multiplier
      ball.y += ball.speed * safeDeltaTime * _speedMultiplier * (1 + (level - 1) * 0.05);
      
      // Check collision zones
      final collisions = checkBallCollision(ball);
      
      if (collisions['inCatchZone']!) {
        ballsInCatchZone.add(ball);
      }
      
      if (collisions['inPerfectZone']!) {
        ballsInPerfectZone.add(ball);
      }
      
      // Check for catches
      if (collisions['inBucket']!) {
        ball.isCaught = true;
        _catchBall(ball);
        ballsToRemove.add(ball);
        continue;
      }
      
      // Check if ball fell off screen
      if (ball.y > 1.5) {
        _missBall(ball);
        ballsToRemove.add(ball);
      }
    }
    
    // Remove caught/missed balls
    balls.removeWhere((ball) => ballsToRemove.contains(ball));
    
    // Spawn new balls (only if level not complete)
    if (!isLevelComplete) {
      final now = DateTime.now();
      if (lastBallSpawn == null || 
          now.difference(lastBallSpawn!).inMilliseconds > ballSpawnInterval) {
        _spawnBall();
        lastBallSpawn = now;
      }
    }
  }
  
  void _catchBall(GameBall ball) {
    final catchDetails = getCatchDetails(ball);
    final quality = catchDetails['quality']!;
    final multiplier = catchDetails['scoreMultiplier']!;
    
    combo++;
    if (combo > maxCombo) maxCombo = combo;
    
    int baseScore = ball.isPowerUp ? 50 : 10;
    int catchScore = (baseScore * combo * multiplier).round();
    
    // Bonus for perfect catches
    if (quality >= 1.3) {
      catchScore = (catchScore * 1.2).round(); // 20% bonus
    }
    
    score += catchScore;
    
    // Track balls caught in current level
    ballsCaughtInLevel++;
    
    // Check for level completion
    if (ballsCaughtInLevel >= ballsRequiredForNextLevel) {
      isLevelComplete = true;
      _completeLevel();
    }
    
    // Check for new high score immediately
    if (score > highScore) {
      highScore = score;
      DataPersistenceService.saveHighScore(highScore);
    }
    
    print('🎯 Ball caught! Level: $level, Caught: $ballsCaughtInLevel/$ballsRequiredForNextLevel, '
          'Score: $score (+$catchScore), Combo: $combo, '
          'Quality: ${(quality * 100).toStringAsFixed(0)}%, '
          'Multiplier: ${multiplier.toStringAsFixed(2)}x');
  }
  
  void _completeLevel() {
    print('🎉 LEVEL $level COMPLETE! 🎉');
    
    // Mark level as completed
    DataPersistenceService.markLevelCompleted(level);
    
    // Unlock next level
    DataPersistenceService.getUnlockedLevels().then((currentUnlocked) {
      if (level == currentUnlocked) {
        DataPersistenceService.saveUnlockedLevels(level + 1);
        print('🔓 Level ${level + 1} unlocked!');
      }
    });
  }
  
  void _missBall(GameBall ball) {
    combo = 0;
    lives--;
    
    if (lives <= 0) {
      _gameOver();
    }
    
    print('💔 Ball missed! Lives: $lives');
  }
  
  void _activatePowerUp(String type) {
    switch (type) {
      case 'slow':
        ballSpawnInterval *= 1.5;
        Future.delayed(const Duration(seconds: 5), () {
          ballSpawnInterval /= 1.5;
        });
        break;
      case 'fast':
        ballSpawnInterval *= 0.5;
        Future.delayed(const Duration(seconds: 5), () {
          ballSpawnInterval /= 0.5;
        });
        break;
      case 'shield':
        lives++;
        break;
      case 'double':
        // Double points for 10 seconds
        break;
    }
  }
  
  void _spawnBall() {
    // Determine number of colors based on level
    int maxColors = min(3 + (level ~/ 3), ballColors.length);
    
    // Chance for power-up increases with level
    bool isPowerUp = random.nextDouble() < (0.03 + level * 0.003);
    
    // Try to find a good position that's not too close to other balls
    double x;
    int attempts = 0;
    do {
      x = (random.nextDouble() * 0.8 + 0.1).clamp(0.0, 1.0);
      attempts++;
      
      // Check if this position is too close to existing balls
      var tooClose = false;
      for (var ball in balls) {
        if ((ball.x - x).abs() < _minBallSpacing) {
          tooClose = true;
          break;
        }
      }
      
      if (!tooClose || attempts > 10) break;
    } while (true);
    
    double size = (0.08 + random.nextDouble() * 0.04).clamp(0.05, 0.15);
    double speed = (0.15 + (level * 0.015)).clamp(0.1, 0.5);
    
    _ballIdCounter++;
    balls.add(GameBall(
      id: _ballIdCounter,
      color: ballColors[random.nextInt(maxColors)],
      x: x,
      y: -0.1,
      speed: speed,
      size: size,
      isPowerUp: isPowerUp,
      powerUpType: isPowerUp ? ['slow', 'fast', 'shield', 'double'][random.nextInt(4)] : '',
    ));
    
    // Gradually increase spawn rate based on difficulty and level
    final difficultyFactor = _difficulty == Difficulty.expert ? 2.0 : 
                           _difficulty == Difficulty.hard ? 1.5 : 1.0;
    ballSpawnInterval = max(800.0, 1500.0 - (level * 15 * difficultyFactor));
  }
  
  void _levelUp() {
    level++;
    // Reward with extra life on easy/medium difficulty
    if (_difficulty == Difficulty.easy || _difficulty == Difficulty.medium) {
      lives++;
    }
  }
  
  void _gameOver() {
    isGameOver = true;
    // Final check for high score
    if (score > highScore) {
      highScore = score;
      DataPersistenceService.saveHighScore(highScore);
    }
  }
  
  // Move bucket to tap position
  void moveBucket(double screenPosition) {
    // Validate position
    if (screenPosition.isNaN || screenPosition.isInfinite) return;
    
    bucketPosition = screenPosition.clamp(0.0, 1.0);
  }
  
  // Get current difficulty
  Difficulty get difficulty => _difficulty;
  
  // Get bucket dimensions for visual alignment
  double getBucketWidth() => bucketWidth;
  double getBucketHeight() => bucketHeight;
  
  // Get level progress
  double getLevelProgress() {
    return ballsCaughtInLevel / ballsRequiredForNextLevel;
  }
}