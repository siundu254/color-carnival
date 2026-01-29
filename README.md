# Color Carnival Game 🎮

A fun and engaging Flutter game where players catch colorful falling balls to progress through levels!

## 🎯 Game Overview

Color Carnival is an interactive mobile game designed for players of all ages (3+). The objective is simple yet challenging: catch falling colored balls using a catcher that you control by swiping left and right. Progress through increasingly difficult levels by catching specific numbers of balls!

## ✨ Features

### 🎮 Core Gameplay
- **Intuitive Controls**: Simple swipe gestures to move the catcher
- **Progressive Difficulty**: 100 levels with increasing challenge
- **Colorful Visuals**: Vibrant colors and smooth animations
- **Power-ups**: Special balls with unique abilities
- **Combo System**: Chain catches for bonus points

### 📱 Game Modes
- **Endless Mode**: Play forever and compete for high scores
- **Level Mode**: Progress through 100 carefully designed levels
- **Practice Mode**: Perfect your catching skills

### 🎨 Visual Elements
- **Dynamic Background**: Gradient backgrounds that change with gameplay
- **Animated Catcher**: Visually appealing catcher with glow effects
- **Particle Effects**: Confetti celebrations and visual feedback
- **Progress Indicators**: Clear visual progress for each level

### ⚙️ Customization
- **Sound Settings**: Toggle music and sound effects
- **Difficulty Levels**: Choose from Easy, Medium, Hard, or Expert
- **Visual Options**: Adjust game appearance to your preference

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Android Studio or VS Code (with Flutter extension)
- Physical device or emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/color-carnival.git
   cd color-carnival
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Project Structure
```
color-carnival/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   ├── home_screen.dart      # Main menu screen
│   │   ├── play_screen.dart      # Gameplay screen
│   │   ├── level_select.dart     # Level selection screen
│   │   └── settings_screen.dart  # Settings screen
│   ├── game/
│   │   └── game_engine.dart      # Core game logic
│   └── utils/
│       ├── constants.dart        # Game constants
│       ├── data_persistence_service.dart # Data storage
│       └── helpers.dart         # Helper functions
├── assets/
│   ├── sounds/                  # Audio files
│   └── images/                  # Image assets
└── pubspec.yaml                # Dependencies and assets
```

## 🎮 How to Play

### Basic Controls
- **Swipe Left/Right**: Move the catcher horizontally
- **Tap Pause**: Pause/resume the game
- **Sound Toggle**: Enable/disable background music

### Game Rules
1. **Objective**: Catch falling balls before they hit the ground
2. **Lives**: Start with 3 lives (lose one for each missed ball)
3. **Scoring**: 
   - Regular ball: 10 points
   - Power-up ball: 50 points
   - Combo multiplier: Increases with consecutive catches
4. **Level Completion**: Catch required number of balls to advance

### Level Progression
| Level | Balls Required | Difficulty Features |
|-------|----------------|---------------------|
| 1-5   | 10-30          | Slow speed, 3 colors |
| 6-15  | 35-80          | Medium speed, 4 colors |
| 16-30 | 85-155         | Fast speed, 5 colors, power-ups |
| 31-50 | 160-255        | Very fast, all colors |
| 51-100| 260-510        | Expert speed, frequent power-ups |

### Power-ups
- **⚡ Speed Boost**: Temporarily increases ball speed
- **🛡️ Shield**: Grants an extra life
- **🐌 Slow Motion**: Slows down balls temporarily
- **2x Multiplier**: Doubles points for a limited time

## 🔧 Technical Details

### Game Engine Architecture

The game uses a custom-built game engine with:
- **Frame-based Updates**: 60 FPS game loop
- **Collision Detection**: Advanced zone-based collision system
- **State Management**: Comprehensive game state tracking
- **Persistence**: Local data storage using SharedPreferences

### Key Components

#### GameEngine Class
```dart
class GameEngine {
  // Game state management
  int score, level, lives, combo;
  List<GameBall> balls;
  
  // Game logic methods
  void update(double deltaTime);
  bool isBallInBucket(GameBall ball);
  void moveBucket(double position);
}
```

#### PlayScreen Class
```dart
class PlayScreen extends StatefulWidget {
  // Manages game rendering, user input, and UI updates
  // Integrates with GameEngine for game logic
  // Handles animations and visual effects
}
```

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  audioplayers: ^5.2.1      # Audio playback
  confetti: ^0.7.0          # Celebration effects
  shared_preferences: ^2.1.0 # Data persistence
  google_fonts: ^4.0.4      # Custom typography
```

## 🎨 Design Philosophy

### Color Scheme
- **Primary**: Blues and purples (#6A67CE to #9D4EDD)
- **Accent**: Bright colors for balls (red, teal, yellow, green, blue, purple)
- **Background**: Deep blue (#0a192f) with gradient overlays

### UI/UX Principles
1. **Simplicity**: Intuitive interface for all ages
2. **Feedback**: Visual and audio feedback for all actions
3. **Accessibility**: Large touch targets, clear contrasts
4. **Engagement**: Rewarding progression system

### Performance Optimization
- **Efficient Rendering**: Minimal widget rebuilds
- **Memory Management**: Proper disposal of resources
- **Smooth Animations**: 60 FPS target for all animations

## 📊 Data Persistence

The game saves:
- High scores
- Unlocked levels
- Completed levels
- User settings (sound, music, difficulty)
- Player preferences

Using `SharedPreferences` for reliable local storage.

## 🚀 Building for Release

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Manual Testing Checklist
- [ ] Game launches successfully
- [ ] All screens render correctly
- [ ] Touch controls work smoothly
- [ ] Audio plays correctly
- [ ] Game saves progress
- [ ] Level progression works
- [ ] Power-ups function properly

## 🐛 Troubleshooting

### Common Issues

1. **Game lags or stutters**
   - Close other running apps
   - Restart the device
   - Ensure sufficient storage space

2. **Sounds not playing**
   - Check device volume
   - Verify sound settings in-game
   - Restart the app

3. **Progress not saving**
   - Check device storage permissions
   - Ensure stable internet connection (for cloud sync if implemented)
   - Restart the app

### Debug Mode
```bash
flutter run --debug
# Check logs for specific errors
```

## 📱 Platform Support

- **Android**: 5.0 (API 21) and higher
- **iOS**: 11.0 and higher
- **Web**: Modern browsers (Chrome, Firefox, Safari, Edge)

## 🔮 Future Enhancements

### Planned Features
- [ ] Multiplayer mode
- [ ] Daily challenges
- [ ] Achievement system
- [ ] Social sharing
- [ ] Cloud save synchronization
- [ ] Additional power-ups
- [ ] Seasonal events

### Technical Improvements
- [ ] Enhanced particle system
- [ ] 3D graphics support
- [ ] Voice control integration
- [ ] AR mode

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Report Bugs**: Use the issue tracker
2. **Suggest Features**: Share your ideas
3. **Submit Pull Requests**: Follow the contribution guidelines
4. **Improve Documentation**: Help make the project clearer

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Contributors and testers
- Open-source community for various packages
- Players for their feedback and support

## 📞 Support

Having trouble? Here's how to get help:

1. **Documentation**: Check this README first
2. **Issues**: Search existing issues or create a new one
3. **Email**: support@colorcarnival.com
4. **Discord**: Join our community server

## 📊 Analytics (Optional Implementation)

The game can integrate with:
- Firebase Analytics for usage tracking
- Crashlytics for error reporting
- Google Play Games Services for achievements

---

**Made with ❤️ by the Color Carnival Team**

*Catch the colors, embrace the fun!* 🎨✨
