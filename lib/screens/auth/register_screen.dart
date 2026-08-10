import 'package:flutter/material.dart';

import '../../data/mock_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String selectedProvince = 'กรุงเทพมหานคร';

  void handleRegister() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')));
      return;
    }
    currentUserProfile['name'] = nameController.text;
    currentUserProfile['email'] = emailController.text;
    currentUserProfile['province'] = selectedProvince;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFFF9E68)),
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('ข้อมูลพื้นฐานบัญชีผู้ใช้',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9E68))),
            const SizedBox(height: 16),
            TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'ชื่อผู้ใช้ / ชื่อเล่น *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 16),
            TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: 'อีเมล / เบอร์โทรศัพท์ *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 16),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'รหัสผ่าน *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 16),
            TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'ยืนยันรหัสผ่าน *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 24),
            const Text('ข้อมูลสถานที่',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9E68))),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedProvince,
              decoration: InputDecoration(
                  labelText: 'จังหวัดที่อยู่ปัจจุบัน',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              items: thaiProvinces
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => setState(() => selectedProvince = val!),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9E68),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 2,
              ),
              child: const Text('สมัครสมาชิก',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
