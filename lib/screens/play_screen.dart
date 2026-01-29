import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_engine.dart';
import '../utils/data_persistence_service.dart';

class PlayScreen extends StatefulWidget {
  final int? startingLevel;
  
  const PlayScreen({super.key, this.startingLevel});
  
  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with SingleTickerProviderStateMixin {
  late GameEngine game;
  Timer? _gameTimer;
  late ConfettiController _confettiController;
  
  // Audio players
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  
  // Catcher properties
  final double _catcherHeight = 75;
  final double _catcherWidth = 200;
  double _catcherPosition = 0.5;
  
  // Screen dimensions
  double _screenWidth = 400;
  double _screenHeight = 800;
  
  // Catcher animation
  late AnimationController _catcherController;
  late Animation<double> _catcherAnimation;
  
  // Visual effects
  List<FloatingScore> _floatingScores = [];
  List<Color> _catchEffects = [];
  List<CatchGlow> _catchGlows = [];
  
  // Game state
  bool _isMusicPlaying = false;
  bool _showTutorial = true;
  Timer? _tutorialTimer;
  bool _gameStarted = false;
  double _catcherEnergy = 0.0;
  
  // Settings loaded from persistence
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  
  // Track balls that have been caught in this frame
  final Set<int> _caughtThisFrame = <int>{};
  
  // Level completion tracking
  bool _showLevelCompleteOverlay = false;

  @override
  void initState() {
    super.initState();
    game = GameEngine();
    
    // Initialize animations
    _catcherController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _catcherAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _catcherController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Initialize confetti
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Don't start game immediately - wait for tutorial to disappear
    game.isPaused = true;
    
    // Load settings from persistence
    _loadSettings();
    
    // Start background music if enabled
    if (_musicEnabled) {
      _playBackgroundMusic();
    }
    
    // Hide tutorial after 5 seconds and start game
    _tutorialTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showTutorial = false;
          _gameStarted = true;
          game.isPaused = false;
        });
        _startGameLoop();
      }
    });
    
    _catcherPosition = game.bucketPosition;
  }
  
  void _loadSettings() async {
    _soundEnabled = await DataPersistenceService.getSoundEnabled();
    _musicEnabled = await DataPersistenceService.getMusicEnabled();
    _vibrationEnabled = await DataPersistenceService.getVibrationEnabled();
    
    // Initialize game after loading settings
    if (widget.startingLevel != null) {
      await game.startLevel(widget.startingLevel!);
    } else {
      await game.startNewGame();
    }
    
    if (mounted) {
      setState(() {});
    }
  }
  
  void _startGameLoop() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
  }
  
  Future<void> _playBackgroundMusic() async {
    if (!_isMusicPlaying && _musicEnabled) {
      try {
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
        await _musicPlayer.play(AssetSource('assets/sounds/background_music.mp3'));
        _isMusicPlaying = true;
      } catch (e) {
        print('Could not play background music: $e');
      }
    }
  }
  
  Future<void> _playSound(String sound) async {
    if (!_soundEnabled) return;
    
    try {
      await _audioPlayer.play(AssetSource(sound));
    } catch (e) {
      print('Could not play sound: $e');
    }
  }
  
  void _updateGame() {
    if (!mounted || game.isGameOver || game.isPaused) return;
    
    // Clear caught balls from previous frame
    _caughtThisFrame.clear();
    
    // Update screen dimensions in game engine
    game.updateScreenDimensions(_screenWidth, _screenHeight);
    
    // Update game logic
    game.update(0.016);
    
    // Check for level completion
    if (game.isLevelComplete && !_showLevelCompleteOverlay) {
      _showLevelCompleteOverlay = true;
      _confettiController.play();
      _playSound('assets/sounds/level_complete.mp3');
    }
    
    // Update catcher energy based on balls in zones
    if (game.ballsInCatchZone.isNotEmpty) {
      _catcherEnergy = (_catcherEnergy * 0.9 + 0.1).clamp(0.0, 1.0);
    } else {
      _catcherEnergy = (_catcherEnergy * 0.8).clamp(0.0, 1.0);
    }
    
    // Update catcher position
    _catcherPosition = game.bucketPosition;
    
    // Update visual effects
    _updateEffects();
    
    // Animate catcher for balls in perfect zone
    if (game.ballsInPerfectZone.isNotEmpty && !_catcherController.isAnimating) {
      _catcherController.repeat(reverse: true);
    } else if (game.ballsInPerfectZone.isEmpty && _catcherController.isAnimating) {
      _catcherController.stop();
      _catcherController.value = 0.0;
    }
    
    if (mounted) {
      setState(() {});
    }
  }
  
  void _onDragStart(DragStartDetails details) {
    if (!_gameStarted) {
      // If tutorial is showing and user drags, hide tutorial and start game
      _tutorialTimer?.cancel();
      if (mounted) {
        setState(() {
          _showTutorial = false;
          _gameStarted = true;
          game.isPaused = false;
        });
        _startGameLoop();
      }
    }
  }
  
  void _onDragUpdate(DragUpdateDetails details) {
    if (!mounted || !_gameStarted || game.isPaused) return;
    
    final screenPosition = details.globalPosition.dx / _screenWidth;
    
    game.moveBucket(screenPosition);
    _catcherPosition = screenPosition.clamp(0.0, 1.0);
    
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    _screenWidth = screenSize.width;
    _screenHeight = screenSize.height;
    
    if (_screenWidth <= 0 || _screenHeight <= 0) {
      return Container(color: const Color(0xFF0a192f));
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF0a192f),
      body: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background with dynamic gradient
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.3, -0.3),
                  radius: 1.5,
                  colors: [
                    const Color(0xFF1a237e).withOpacity(0.8 + _catcherEnergy * 0.2),
                    const Color(0xFF0d47a1).withOpacity(0.6 + _catcherEnergy * 0.2),
                    const Color(0xFF0a192f).withOpacity(0.9),
                  ],
                ),
              ),
            ),
            
            // Catch zone visualization
            if (_gameStarted && !game.isPaused)
              _buildCatchZones(),
            
            // Game elements
            _buildGameElements(),
            
            // Creative Catcher
            if (_gameStarted && !game.isPaused) 
              Positioned(
                left: _catcherPosition * _screenWidth - (_catcherWidth / 2),
                bottom: 160,
                child: _buildCreativeCatcher(),
              ),
            
            // UI Overlay - Header at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildHeader(),
            ),
            
            // Control buttons
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: _buildControlButtons(),
            ),
            
            // Tutorial overlay
            if (_showTutorial) _buildTutorialOverlay(),
            
            // Level complete overlay
            if (_showLevelCompleteOverlay) _buildLevelCompleteOverlay(),
            
            // Game over overlay
            if (game.isGameOver) _buildGameOverOverlay(),
            
            // Celebration effects
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: GameEngine.ballColors,
              gravity: 0.1,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCatchZones() {
    final catcherLeft = _catcherPosition * _screenWidth - (_catcherWidth / 2);
    final catcherTop = _screenHeight - 160 - _catcherHeight;
    final perfectZoneWidth = _catcherWidth * 0.6;
    
    return Stack(
      children: [
        // Catch zone (subtle glow) - EXACTLY MATCHES VISUAL CATCHER
        Positioned(
          left: catcherLeft,
          top: catcherTop,
          child: Container(
            width: _catcherWidth,
            height: _catcherHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withOpacity(0.15 * _catcherEnergy),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
        ),
        
        // Perfect zone (center highlight)
        Positioned(
          left: _catcherPosition * _screenWidth - (perfectZoneWidth / 2),
          top: catcherTop,
          child: Container(
            width: perfectZoneWidth,
            height: _catcherHeight,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.5),
                radius: 1.5,
                colors: [
                  Colors.yellow.withOpacity(0.3 * _catcherEnergy),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        
        // Catch glow effects
        ..._catchGlows.map((glow) {
          final progress = DateTime.now().difference(glow.startTime).inMilliseconds / 500.0;
          final opacity = (1.0 - progress).clamp(0.0, 1.0);
          final scale = 1.0 + progress * 0.5;
          
          return Positioned(
            left: glow.x * _screenWidth - (glow.size * _screenWidth * scale / 2),
            top: glow.y * _screenHeight - (glow.size * _screenHeight * scale / 2),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: glow.size * _screenWidth * scale,
                height: glow.size * _screenHeight * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      glow.color.withOpacity(0.8),
                      glow.color.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildGameElements() {
    return Stack(
      children: [
        // Falling balls
        ...game.balls.map((ball) {
          // Validate ball position
          if (ball.x.isNaN || ball.y.isNaN || ball.size.isNaN ||
              ball.x.isInfinite || ball.y.isInfinite || ball.size.isInfinite) {
            return Container();
          }
          
          final left = ball.x * _screenWidth - (ball.size * _screenWidth / 2);
          final top = ball.y * _screenHeight;
          
          // Ensure valid positioning
          if (left.isNaN || left.isInfinite || top.isNaN || top.isInfinite) {
            return Container();
          }
          
          // Check if ball is being caught
          if (ball.isCaught && !_caughtThisFrame.contains(ball.hashCode)) {
            _caughtThisFrame.add(ball.hashCode);
            _onBallCaught(ball);
          }
          
          // Add glow effect if ball is in catch zone
          final isInCatchZone = game.ballsInCatchZone.contains(ball);
          final isInPerfectZone = game.ballsInPerfectZone.contains(ball);
          
          return Positioned(
            left: left,
            top: top,
            child: Container(
              width: ball.size * _screenWidth,
              height: ball.size * _screenWidth,
              decoration: BoxDecoration(
                color: ball.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ball.color.withOpacity(isInPerfectZone ? 0.9 : 0.7),
                    blurRadius: isInCatchZone ? 30 : 15,
                    spreadRadius: isInCatchZone ? 8 : 3,
                  ),
                  if (isInPerfectZone)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: ball.isPowerUp
                  ? Center(
                      child: Container(
                        width: ball.size * _screenWidth * 0.7,
                        height: ball.size * _screenWidth * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: ball.color, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            _getPowerUpSymbol(ball.powerUpType),
                            style: TextStyle(
                              color: ball.color,
                              fontSize: max(ball.size * _screenWidth * 0.2, 12),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          );
        }).toList(),
        
        // Floating scores
        ..._floatingScores.map((score) {
          final age = DateTime.now().difference(score.startTime).inMilliseconds;
          final progress = age / 1000.0;
          
          final opacity = (1.0 - progress).clamp(0.0, 1.0);
          
          return Positioned(
            left: score.x * _screenWidth,
            top: score.y * _screenHeight - (progress * 100),
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: 1.0 + progress * 0.3,
                child: Text(
                  '+${score.value}',
                  style: GoogleFonts.comicNeue(
                    fontSize: 24 + (progress * 10),
                    fontWeight: FontWeight.bold,
                    color: score.color,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildCreativeCatcher() {
    return AnimatedBuilder(
      animation: _catcherAnimation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..scale(1.0, 1.0 + _catcherAnimation.value * 0.1),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: _catcherWidth,
            height: _catcherHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00E5FF).withOpacity(0.9),
                  const Color(0xFF2979FF),
                  const Color(0xFF304FFE),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.5),
                  blurRadius: 25,
                  spreadRadius: 8,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, -2),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Inner gradient
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                
                // Center highlight
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: _catcherWidth * 0.6,
                      height: _catcherHeight * 0.6,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Side arms
                Positioned(
                  left: 0,
                  top: _catcherHeight * 0.3,
                  child: Container(
                    width: 20,
                    height: _catcherHeight * 0.4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00E5FF),
                          const Color(0xFF304FFE),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
                
                Positioned(
                  right: 0,
                  top: _catcherHeight * 0.3,
                  child: Container(
                    width: 20,
                    height: _catcherHeight * 0.4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00E5FF),
                          const Color(0xFF304FFE),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
                
                // Text
                Center(
                  child: Text(
                    'CATCH ZONE',
                    style: GoogleFonts.comicNeue(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Animation particles
                if (game.ballsInPerfectZone.isNotEmpty)
                  ...List.generate(5, (index) {
                    return Positioned.fill(
                      child: Align(
                        alignment: Alignment(
                          -0.8 + (index * 0.4),
                          -0.5 + _catcherAnimation.value,
                        ),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row: Back button and stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () {
                    _musicPlayer.stop();
                    _gameTimer?.cancel();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                
                // Level and score
                _buildStatCard(
                  'Level ${game.level}',
                  Icons.flag,
                  Colors.green,
                ),
                
                // Score
                _buildStatCard(
                  '${game.score}',
                  Icons.star,
                  Colors.amber,
                ),
                
                // Combo
                if (game.combo > 1)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.8),
                          Colors.red.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${game.combo}x COMBO',
                          style: GoogleFonts.comicNeue(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Lives
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${game.lives}',
                        style: GoogleFonts.comicNeue(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Level progress bar
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level ${game.level}',
                        style: GoogleFonts.comicNeue(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${game.ballsCaughtInLevel}/${game.ballsRequiredForNextLevel} Balls',
                        style: GoogleFonts.comicNeue(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: game.getLevelProgress(),
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      GameEngine.ballColors[game.level % GameEngine.ballColors.length],
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String value, IconData icon, Color color, 
                       {bool showHighScore = false, int highScore = 0}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.7),
            color.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.9), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                value,
                style: GoogleFonts.comicNeue(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (showHighScore && highScore > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Best: $highScore',
                style: GoogleFonts.comicNeue(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLevelCompleteOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4CAF50),
                        Color(0xFF8BC34A),
                        Color(0xFFCDDC39),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'LEVEL ${game.level} COMPLETE!',
                        style: GoogleFonts.comicNeue(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(3, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '🎉 You caught ${game.ballsCaughtInLevel} balls! 🎉',
                        style: GoogleFonts.comicNeue(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Level ${game.level + 1} awaits!',
                              style: GoogleFonts.comicNeue(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Catch ${10 + (game.level * 5)} balls to complete',
                              style: GoogleFonts.comicNeue(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Start next level
                              await game.startLevel(game.level + 1);
                              _showLevelCompleteOverlay = false;
                              _gameStarted = true;
                              game.isPaused = false;
                              _startGameLoop();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 10,
                            ),
                            icon: const Icon(Icons.play_arrow, size: 24),
                            label: Text(
                              'NEXT LEVEL',
                              style: GoogleFonts.comicNeue(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _musicPlayer.stop();
                              _gameTimer?.cancel();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 10,
                            ),
                            icon: const Icon(Icons.home, size: 24),
                            label: Text(
                              'GO HOME',
                              style: GoogleFonts.comicNeue(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Replay same level
                              await game.startLevel(game.level);
                              _showLevelCompleteOverlay = false;
                              _gameStarted = true;
                              game.isPaused = false;
                              _startGameLoop();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 10,
                            ),
                            icon: const Icon(Icons.replay, size: 24),
                            label: Text(
                              'PLAY AGAIN',
                              style: GoogleFonts.comicNeue(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause/Play button
        GestureDetector(
          onTap: () {
            if (!_gameStarted) return;
            
            setState(() {
              game.isPaused = !game.isPaused;
              if (game.isPaused) {
                _gameTimer?.cancel();
                _catcherController.stop();
              } else {
                _startGameLoop();
              }
            });
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gameStarted 
                  ? [Colors.blue, Colors.purple]
                  : [Colors.grey, Colors.grey[700]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Icon(
              !_gameStarted ? Icons.play_arrow : 
              (game.isPaused ? Icons.play_arrow : Icons.pause),
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Sound toggle
        GestureDetector(
          onTap: () {
            setState(() {
              _isMusicPlaying = !_isMusicPlaying;
              _musicEnabled = !_musicEnabled;
              DataPersistenceService.saveMusicEnabled(_musicEnabled);
              
              if (_isMusicPlaying) {
                _playBackgroundMusic();
              } else {
                _musicPlayer.stop();
              }
            });
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.teal],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Icon(
              _isMusicPlaying ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTutorialOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1a237e),
                  Color(0xFF0d47a1),
                  Color(0xFF1565C0),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.blue, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🚀 HOW TO PLAY',
                  style: GoogleFonts.comicNeue(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 25),
                _buildTutorialItem('🔄', 'Swipe horizontally to move the catcher'),
                _buildTutorialItem('🎯', 'Line up with falling balls for perfect catches'),
                _buildTutorialItem('✨', 'Center gives bonus points!'),
                _buildTutorialItem('❤️', 'You have ${game.lives} lives - don\'t miss!'),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.yellow, width: 2),
                  ),
                  child: Text(
                    'Swipe anywhere to begin your journey!',
                    style: GoogleFonts.comicNeue(
                      fontSize: 20,
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTutorialItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.comicNeue(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameOverOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.95),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1a237e),
                        Color(0xFF0d47a1),
                        Color(0xFF1565C0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.blue, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'GAME OVER',
                        style: GoogleFonts.comicNeue(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(3, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        '🎉 FINAL SCORE 🎉',
                        style: GoogleFonts.comicNeue(
                          fontSize: 28,
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '${game.score}',
                        style: GoogleFonts.comicNeue(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'High Score: ${game.highScore}',
                        style: GoogleFonts.comicNeue(
                          fontSize: 22,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (game.score > game.highScore)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                              const SizedBox(width: 10),
                              Text(
                                '🏆 NEW HIGH SCORE! 🏆',
                                style: GoogleFonts.comicNeue(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                            ],
                          ),
                        ),
                      const SizedBox(height: 30),
                      Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await game.startNewGame();
                              _floatingScores.clear();
                              _catchEffects.clear();
                              _catchGlows.clear();
                              _caughtThisFrame.clear();
                              _gameStarted = true;
                              game.isPaused = false;
                              _startGameLoop();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 10,
                            ),
                            icon: const Icon(Icons.play_arrow, size: 24),
                            label: Text(
                              'PLAY AGAIN',
                              style: GoogleFonts.comicNeue(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _musicPlayer.stop();
                              _gameTimer?.cancel();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 10,
                            ),
                            icon: const Icon(Icons.home, size: 24),
                            label: Text(
                              'GO HOME',
                              style: GoogleFonts.comicNeue(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _onBallCaught(GameBall ball) {
    final catchDetails = game.getCatchDetails(ball);
    final quality = catchDetails['quality']!;
    
    // Add catch glow effect
    _catchGlows.add(CatchGlow(
      color: ball.color,
      x: ball.x,
      y: ball.y,
      size: ball.size * 1.5,
      startTime: DateTime.now(),
    ));
    
    // Add floating score with quality indicator
    String scoreText = ball.isPowerUp ? '50' : '10';
    if (quality >= 1.3) {
      scoreText += '✨';
    } else if (quality >= 1.0) {
      scoreText += '★';
    }
    
    _floatingScores.add(FloatingScore(
      value: game.combo > 1 ? '${scoreText} x${game.combo}' : scoreText,
      x: ball.x,
      y: ball.y,
      color: quality >= 1.3 ? Colors.yellow : ball.color,
      startTime: DateTime.now(),
    ));
    
    // Play catch sound based on quality
    if (quality >= 1.3) {
      _playSound('assets/sounds/perfect_catch.mp3');
    } else {
      _playSound('assets/sounds/catch.mp3');
    }
    
    // Remove catch effect after delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _catchEffects.contains(ball.color)) {
        setState(() {
          _catchEffects.remove(ball.color);
        });
      }
    });
    
    // Remove glow after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _catchGlows.removeWhere((glow) => glow.color == ball.color);
        });
      }
    });
    
    // Force immediate UI update
    if (mounted) {
      setState(() {});
    }
  }
  
  void _updateEffects() {
    final now = DateTime.now();
    
    // Update floating scores
    _floatingScores.removeWhere((score) {
      return now.difference(score.startTime).inMilliseconds > 1000;
    });
    
    // Update catch glows
    _catchGlows.removeWhere((glow) {
      return now.difference(glow.startTime).inMilliseconds > 500;
    });
  }
  
  String _getPowerUpSymbol(String type) {
    switch (type) {
      case 'slow': return '🐌';
      case 'fast': return '⚡';
      case 'shield': return '🛡️';
      case 'double': return '2x';
      default: return '✨';
    }
  }
  
  @override
  void dispose() {
    _tutorialTimer?.cancel();
    _gameTimer?.cancel();
    _confettiController.dispose();
    _catcherController.dispose();
    _audioPlayer.dispose();
    _musicPlayer.dispose();
    super.dispose();
  }
}

// Helper classes for visual effects
class FloatingScore {
  final String value;
  final double x;
  final double y;
  final Color color;
  final DateTime startTime;
  
  FloatingScore({
    required this.value,
    required this.x,
    required this.y,
    required this.color,
    required this.startTime,
  });
}

class CatchGlow {
  final Color color;
  final double x;
  final double y;
  final double size;
  final DateTime startTime;
  
  CatchGlow({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.startTime,
  });
}