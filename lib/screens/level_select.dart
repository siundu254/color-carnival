import 'package:flutter/material.dart';
import 'play_screen.dart';
import '../utils/constants.dart';
import '../utils/data_persistence_service.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _unlockedLevels = 1; // Start with only level 1 unlocked
  List<int> _completedLevels = [];
  int _nextLevelToPlay = 1; // Track which level should be played next
  
  @override
  void initState() {
    super.initState();
    _loadLevelData();
  }
  
  void _loadLevelData() async {
    final unlocked = await DataPersistenceService.getUnlockedLevels();
    final completed = await DataPersistenceService.getCompletedLevels();
    
    // Calculate next level to play (lowest uncompleted unlocked level)
    int nextLevel = 1;
    for (int level = 1; level <= unlocked; level++) {
      if (!completed.contains(level)) {
        nextLevel = level;
        break;
      }
    }
    // If all unlocked levels are completed, play the next locked level
    if (nextLevel > unlocked) {
      nextLevel = unlocked + 1;
    }
    
    if (mounted) {
      setState(() {
        _unlockedLevels = unlocked;
        _completedLevels = completed;
        _nextLevelToPlay = nextLevel;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f3460),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Select Level',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6A67CE),
                      Color(0xFF9D4EDD),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            pinned: true,
            elevation: 10,
          ),
          
          // Quick Play Button for Next Level
          SliverPadding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            sliver: SliverToBoxAdapter(
              child: _buildQuickPlayButton(context),
            ),
          ),
          
          // Level Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final level = index + 1;
                  final isUnlocked = level <= _unlockedLevels;
                  final isCompleted = _completedLevels.contains(level);
                  final isNextLevel = level == _nextLevelToPlay;
                  
                  return _buildLevelCard(context, level, isUnlocked, isCompleted, isNextLevel);
                },
                childCount: 100, // Show 100 levels
              ),
            ),
          ),
          
          // Stats Footer
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 30, top: 10),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Progress: ${_completedLevels.length}/100 Levels • Next: Level $_nextLevelToPlay',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: _completedLevels.length / 100,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _completedLevels.length >= 50 ? Colors.green : 
                          _completedLevels.length >= 20 ? Colors.blue : Colors.orange,
                        ),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickPlayButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00FF87),
            const Color(0xFF00D4FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayScreen(startingLevel: _nextLevelToPlay),
              ),
            ).then((_) {
              // Reload level data when returning from game
              _loadLevelData();
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PLAY NEXT LEVEL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Level $_nextLevelToPlay',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_nextLevelToPlay > _unlockedLevels)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'NEW!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
  
  Widget _buildLevelCard(BuildContext context, int level, bool isUnlocked, bool isCompleted, bool isNextLevel) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayScreen(startingLevel: level),
                ),
              ).then((_) {
                // Reload level data when returning from game
                _loadLevelData();
              });
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isUnlocked
              ? LinearGradient(
                  colors: isNextLevel
                      ? [Colors.orange, Colors.yellow] // Highlight next level
                      : isCompleted
                          ? [Colors.green.withOpacity(0.8), Colors.lightGreen.withOpacity(0.8)] // Completed
                          : [
                              GameConstants.ballColors[(level - 1) % GameConstants.ballColors.length],
                              GameConstants.ballColors[(level) % GameConstants.ballColors.length],
                            ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFF555555),
                    Color(0xFF333333),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: isNextLevel
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
          border: Border.all(
            color: isNextLevel
                ? Colors.yellow.withOpacity(0.8)
                : isUnlocked
                    ? Colors.white.withOpacity(0.5)
                    : Colors.grey.shade700,
            width: isNextLevel ? 3 : 2,
          ),
        ),
        child: Stack(
          children: [
            // Level content - centered
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Level emoji for first few levels
                  if (level <= 15)
                    Text(
                      _getLevelEmoji(level),
                      style: TextStyle(
                        fontSize: 24,
                        color: isUnlocked ? Colors.white : Colors.grey,
                      ),
                    ),
                  
                  // Level number
                  Text(
                    '$level',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  
                  // Level status indicator
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      isNextLevel ? 'NEXT' : (isCompleted ? 'COMPLETED' : ''),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isNextLevel ? Colors.yellow : Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Lock icon for locked levels
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            
            // Status indicators
            if (isCompleted)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            
            if (isNextLevel && !isCompleted)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  String _getLevelEmoji(int level) {
    final emojis = ['🌈', '🎨', '⚡', '🌟', '✨', '🌀', '🌌', '🌸', '🌠', '💎', '❄️', '🔥', '🌿', '🌊', '🌅'];
    return emojis[(level - 1) % emojis.length];
  }
}