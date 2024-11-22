import 'package:flutter/material.dart';
import 'package:foodordering/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOFE Eats',
      theme: ThemeData(
        // Set color scheme for the app
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 69, 210, 9),
        ),
        scaffoldBackgroundColor: Colors.white, // Background color
        useMaterial3: true,
      ),
      home: HomeScreen(), // Show home screen first when app runs
    );
  }
}