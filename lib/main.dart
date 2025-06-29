import 'package:flutter/material.dart';
import 'home.dart'; // We still need to import the file
import 'quiz.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // The home is still our main page structure
      home: const MyHomePage(title: 'Multicult App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(), // Corresponds to index 0 (Home)
    QuizPage(), // Corresponds to index 1 (Business)
    SettingPage(), // Corresponds to index 2 (School)
  ];

  void _onItemTapped(int index) {
    // setState() notifies the framework that the state has changed,
    // causing the UI to rebuild with the new index.
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar from main.dart is kept
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // The body now directly displays the SecondScreen widget
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Quiz',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
                ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
        // The function to call when an item is tapped.
            onTap: _onItemTapped,
          ),
    );
  }
}
