import 'package:flutter/material.dart';

// This is now a simple, reusable widget.
// It no longer has a Scaffold or AppBar.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedOption = 'MCQ';
  final List<String> options = ['MCQ', 'Chat', 'Test'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.blueGrey[800],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Home',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            DropdownButton<String>(
              value: selectedOption,
              dropdownColor: Colors.blueGrey[700],
              style: const TextStyle(color: Colors.white, fontSize: 18),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedOption = newValue;
                  });
                }
              },
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }
}
