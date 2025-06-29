import 'package:flutter/material.dart';
import 'globals.dart' as globals;

// This is now a simple, reusable widget.
// It no longer has a Scaffold or AppBar.
class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    // It just returns the content that should be displayed.
    return const Center(
      child: Text(
        'This is the content from the quiz file!',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
