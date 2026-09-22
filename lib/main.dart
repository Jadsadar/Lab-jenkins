import 'package:flutter/material.dart';

import 'data/mock_data.dart';
import 'screens/auth/create_profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'shared/app_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // เช็ค token ที่ค้างอยู่ในเครื่อง (ถ้ามี) ก่อนวาดหน้าแรก กันไม่ให้ผู้ใช้ที่
  // เคยล็อกอินไว้แล้วต้องเห็นหน้า login วูบหนึ่งก่อนสลับไป MainScreen
  await AuthService.instance.restoreSession();
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

/// ฟังสถานะการล็อกอินแล้วสลับหน้าให้อัตโนมัติ
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
      builder: (context, snapshot) {
        // ห้ามเช็ค ConnectionState.waiting ที่นี่: StreamBuilder จะตั้งสถานะเป็น
        // waiting ทันทีที่ subscribe และค้างอยู่จนกว่า stream จะส่ง event แรก แต่
        // _controller เป็น broadcast (ไม่ replay ให้ subscriber ที่มาทีหลัง) และ
        // restoreSession() ยิง event ไปตั้งแต่ก่อน runApp() แล้ว — event นั้นจึงหาย
        // ไปก่อน AuthGate จะ subscribe ทัน ถ้าดัก waiting ไว้ = ค้างหน้าโหลดตลอดกาล
        //
        // ค่าที่ถูกต้องมาทาง initialData: currentUser อยู่แล้ว เพราะ main() await
        // restoreSession() จนเสร็จก่อนวาดเฟรมแรก
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        // profileCompleted = false คือบัญชีที่เพิ่งสมัคร ยังไม่เคยกรอกหน้าโปรไฟล์
        // (ดู migration 011_profile_completed.sql — แทนที่การเช็ก displayName ว่างแบบเดิม)
        if (!user.profileCompleted) {
          return const CreateProfileScreen();
        }
        currentUserProfile['name'] = user.displayName;
        currentUserProfile['email'] = user.email;
        return const MainScreen();
      },
    );
  }
}
