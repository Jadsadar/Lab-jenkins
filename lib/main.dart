import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/mock_data.dart';
import 'firebase_options.dart';
import 'screens/auth/create_profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: const AuthGate(),
    );
  }
}

/// ฟังสถานะการล็อกอินจาก Firebase แล้วสลับหน้าให้อัตโนมัติ
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        if (user.displayName == null || user.displayName!.isEmpty) {
          return const CreateProfileScreen();
        }
        currentUserProfile['name'] = user.displayName!;
        currentUserProfile['email'] = user.email ?? currentUserProfile['email'];
        return const MainScreen();
      },
    );
  }
}
