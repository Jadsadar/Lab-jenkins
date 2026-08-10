import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';

void main() {
  runApp(const PetPawsApp());
}

class PetPawsApp extends StatelessWidget {
  const PetPawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetPaws',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB085)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF6F0),
      ),
      home: const LoginScreen(),
    );
  }
}
