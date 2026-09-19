import 'package:flutter/material.dart';

import 'login_screen.dart';

// Every Flutter app starts here.
void main() {
  runApp(const MyApp());
}

// The root widget of the app. It sets the theme and the first screen.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Chat Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0175C2)),
        useMaterial3: true,
      ),
      // The first screen the user sees.
      home: const LoginScreen(),
    );
  }
}


