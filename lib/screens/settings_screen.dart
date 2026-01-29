import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/helpers.dart';
import '../utils/data_persistence_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  bool _colorblindMode = false;
  Difficulty _difficulty = Difficulty.easy;
  
  // Kid profile
  String _kidName = 'Super Player';
  int _kidAge = 5;
  String _favoriteColor = 'Blue';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  void _loadSettings() async {
    final soundEnabled = await DataPersistenceService.getSoundEnabled();
    final musicEnabled = await DataPersistenceService.getMusicEnabled();
    final vibrationEnabled = await DataPersistenceService.getVibrationEnabled();
    final colorblindMode = await DataPersistenceService.getColorblindMode();
    final difficulty = await DataPersistenceService.getDifficulty();
    final userName = await DataPersistenceService.getUserName();
    final userAge = await DataPersistenceService.getUserAge();
    final favoriteColor = await DataPersistenceService.getFavoriteColor();
    
    if (mounted) {
      setState(() {
        _soundEnabled = soundEnabled;
        _musicEnabled = musicEnabled;
        _vibrationEnabled = vibrationEnabled;
        _colorblindMode = colorblindMode;
        _difficulty = difficulty;
        _kidName = userName;
        _kidAge = userAge;
        _favoriteColor = favoriteColor;
      });
    }
  }
  
  void _saveSettings() {
    DataPersistenceService.saveSoundEnabled(_soundEnabled);
    DataPersistenceService.saveMusicEnabled(_musicEnabled);
    DataPersistenceService.saveVibrationEnabled(_vibrationEnabled);
    DataPersistenceService.saveColorblindMode(_colorblindMode);
    DataPersistenceService.saveDifficulty(_difficulty);
    DataPersistenceService.saveUserName(_kidName);
    DataPersistenceService.saveUserAge(_kidAge);
    DataPersistenceService.saveFavoriteColor(_favoriteColor);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'My Settings',
                style: GoogleFonts.comicNeue(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A67CE), Color(0xFF9D4EDD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            pinned: true,
            elevation: 10,
          ),
          
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Kid Profile Card
                _buildKidProfileCard(),
                const SizedBox(height: 20),
                
                // Game Settings
                _buildSectionTitle('🎮 Game Settings'),
                _buildSettingCard([
                  _buildKidToggle('Sound Effects', '🔊', _soundEnabled, (value) {
                    setState(() => _soundEnabled = value);
                    DataPersistenceService.saveSoundEnabled(value);
                  }),
                  _buildKidToggle('Background Music', '🎵', _musicEnabled, (value) {
                    setState(() => _musicEnabled = value);
                    DataPersistenceService.saveMusicEnabled(value);
                  }),
                  _buildKidToggle('Vibration', '📳', _vibrationEnabled, (value) {
                    setState(() => _vibrationEnabled = value);
                    DataPersistenceService.saveVibrationEnabled(value);
                  }),
                  _buildKidToggle('Color Help Mode', '👁️', _colorblindMode, (value) {
                    setState(() => _colorblindMode = value);
                    DataPersistenceService.saveColorblindMode(value);
                  }),
                ]),
                const SizedBox(height: 20),
                
                // Difficulty Selector
                _buildSectionTitle('🎯 Game Difficulty'),
                _buildDifficultySelector(),
                const SizedBox(height: 20),
                
                // About Section
                _buildSectionTitle('📱 About The Game'),
                _buildAboutCard(),
                const SizedBox(height: 20),
                
                // Reset Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _showResetDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade800,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: const Icon(Icons.restart_alt),
                    label: Text(
                      'Reset Everything',
                      style: GoogleFonts.comicNeue(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildKidProfileCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FC3F7), Color(0xFF0277BD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Kid Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: Text(
                  '👤',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Kid Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _kidName,
                    style: GoogleFonts.comicNeue(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Age: $_kidAge years',
                    style: GoogleFonts.comicNeue(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    'Favorite Color: $_favoriteColor',
                    style: GoogleFonts.comicNeue(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Difficulty: ${_difficulty.name} ${GameHelpers.getDifficultyIcon(_difficulty)}',
                    style: GoogleFonts.comicNeue(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Edit Button
            IconButton(
              onPressed: _editKidProfile,
              icon: const Icon(Icons.edit, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.comicNeue(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF6A67CE),
        ),
      ),
    );
  }
  
  Widget _buildSettingCard(List<Widget> children) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: children),
      ),
    );
  }
  
  Widget _buildKidToggle(String title, String emoji, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.comicNeue(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (newValue) {
              onChanged(newValue);
            },
            activeColor: const Color(0xFF6A67CE),
            thumbIcon: MaterialStateProperty.all(const Icon(Icons.check)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDifficultySelector() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(GameHelpers.getDifficultyIcon(_difficulty), style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  'How hard should the game be?',
                  style: GoogleFonts.comicNeue(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: Difficulty.values.map((difficulty) {
                final isSelected = _difficulty == difficulty;
                return ChoiceChip(
                  label: Text(
                    '${difficulty.name} ${GameHelpers.getDifficultyIcon(difficulty)}',
                    style: GoogleFonts.comicNeue(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _difficulty = difficulty);
                      DataPersistenceService.saveDifficulty(difficulty);
                    }
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: const Color(0xFF6A67CE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${_difficulty.lives} lives • ${_difficulty.speedMultiplier}x speed',
                style: GoogleFonts.comicNeue(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAboutCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color Catch Carnival',
              style: GoogleFonts.comicNeue(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6A67CE),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.comicNeue(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '🎪 A fun game to help kids learn colors and improve hand-eye coordination!',
              style: GoogleFonts.comicNeue(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Made with ❤️', 'by Flutter Games'),
            _buildInfoRow('For ages', '3+ years'),
            _buildInfoRow('Contact us', 'hello@colorcatch.com'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.comicNeue(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.comicNeue(
              fontSize: 16,
              color: const Color(0xFF6A67CE),
            ),
          ),
        ],
      ),
    );
  }
  
  void _editKidProfile() {
    final nameController = TextEditingController(text: _kidName);
    final ageController = TextEditingController(text: _kidAge.toString());
    final colorController = TextEditingController(text: _favoriteColor);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.comicNeue(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: nameController,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Your Age',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: ageController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Favorite Color',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: colorController,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _kidName = nameController.text.isNotEmpty ? nameController.text : 'Super Player';
                final age = int.tryParse(ageController.text);
                if (age != null && age > 0 && age < 100) {
                  _kidAge = age;
                }
                _favoriteColor = colorController.text.isNotEmpty ? colorController.text : 'Blue';
              });
              _saveSettings();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A67CE),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '⚠️ Reset Everything?',
          style: GoogleFonts.comicNeue(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will reset all your settings, scores, and unlocked levels. Are you sure?',
          style: GoogleFonts.comicNeue(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DataPersistenceService.resetAllData();
              Navigator.pop(context);
              _loadSettings(); // Reload default settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ Everything has been reset!',
                    style: GoogleFonts.comicNeue(fontSize: 16),
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}