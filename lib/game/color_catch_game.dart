import 'package:flutter/material.dart';

// Simple game component without complex animations
class ColorCatchGame extends StatefulWidget {
  const ColorCatchGame({super.key});
  
  @override
  State<ColorCatchGame> createState() => _ColorCatchGameState();
}

class _ColorCatchGameState extends State<ColorCatchGame> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F8FF),
      child: Center(
        child: Container(
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class PlayerComponent extends RectangleComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    paint = Paint()..color = Colors.blue;
    
    // Make it rounded
    anchor = Anchor.center;
  }
}