// import 'package:flutter/material.dart';

// class PetNetworkImage extends StatelessWidget {
//   final String? imageUrl;
//   final BoxFit fit;
//   final double? width;
//   final double? height;
//   final BorderRadius? borderRadius;
//   final Color backgroundColor;
//   final Color iconColor;
//   final double iconSize;
//   final IconData fallbackIcon;

//   const PetNetworkImage({
//     super.key,
//     required this.imageUrl,
//     this.fit = BoxFit.cover,
//     this.width,
//     this.height,
//     this.borderRadius,
//     this.backgroundColor = const Color(0xFFFFF6F0),
//     this.iconColor = Colors.black12,
//     this.iconSize = 64,
//     this.fallbackIcon = Icons.pets,
//   });

//   bool get _hasValidUrl {
//     final url = imageUrl?.trim();
//     if (url == null || url.isEmpty) return false;
//     final uri = Uri.tryParse(url);
//     return uri != null && uri.hasScheme && uri.host.isNotEmpty;
//   }

//   Widget _fallback() => Container(
//         width: width,
//         height: height,
//         color: backgroundColor,
//         child: Center(
//           child: Icon(fallbackIcon, size: iconSize, color: iconColor),
//         ),
//       );

//   @override
//   Widget build(BuildContext context) {
//     final child = !_hasValidUrl
//         ? _fallback()
//         : Image.network(
//             imageUrl!.trim(),
//             width: width,
//             height: height,
//             fit: fit,
//             webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
//             errorBuilder: (context, error, stackTrace) => _fallback(),
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Container(
//                 width: width,
//                 height: height,
//                 color: backgroundColor,
//                 child: Center(
//                   child: SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: iconColor.withOpacity(0.45),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );

//     if (borderRadius == null) return child;
//     return ClipRRect(borderRadius: borderRadius!, child: child);
//   }
// }

// class PetAvatar extends StatelessWidget {
//   final String? imageUrl;
//   final double radius;
//   final IconData icon;
//   final Color backgroundColor;
//   final Color iconColor;

//   const PetAvatar({
//     super.key,
//     required this.imageUrl,
//     this.radius = 24,
//     this.icon = Icons.pets,
//     this.backgroundColor = const Color(0xFFFFF6F0),
//     this.iconColor = const Color(0xFFFF9E68),
//   });

//   bool get _hasValidUrl {
//     final url = imageUrl?.trim();
//     if (url == null || url.isEmpty) return false;
//     final uri = Uri.tryParse(url);
//     return uri != null && uri.hasScheme && uri.host.isNotEmpty;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ClipOval(
//       child: SizedBox(
//         width: radius * 2,
//         height: radius * 2,
//         child: PetNetworkImage(
//           imageUrl: _hasValidUrl ? imageUrl : null,
//           width: radius * 2,
//           height: radius * 2,
//           fit: BoxFit.cover,
//           backgroundColor: backgroundColor,
//           iconColor: iconColor,
//           iconSize: radius,
//           fallbackIcon: icon,
//         ),
//       ),
//     );
//   }
// }

// // ข้อมูลโปรไฟล์ของผู้ใช้ปัจจุบัน
// Map<String, dynamic> currentUserProfile = {
//   "name": "แพรว",
//   "email": "praew@email.com",
//   "province": "กรุงเทพมหานคร",
//   "phone": "089-1234567",
//   "lineId": "praew_line",
//   "fbLink": "facebook.com/praew",
//   "homeType": "บ้านเดี่ยว",
//   "role": "ฉันอยากหาหมาไปเลี้ยง (Adopter)",
//   "profileImageUrl":
//       "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=60",
//   "traits": <String>['สายชิล', 'ชอบอยู่บ้าน']
// };

// // Mock Data inbox (Global เพื่อให้ badge อัปเดตได้)
// List<Map<String, dynamic>> mockInboxChats = [
//   {
//     "chatId": "chat_1",
//     "customerName": "มิน",
//     "customerAvatar":
//         "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=60",
//     "dogName": "ลาเต้",
//     "lastMessage": "สวัสดีครับ สนใจรับเลี้ยงน้องลาเต้ครับ ยังว่างอยู่ไหม?",
//     "time": "10:30",
//     "unread": 2,
//     "messages": [
//       {
//         "text": "สวัสดีครับ สนใจรับเลี้ยงน้องลาเต้ครับ ยังว่างอยู่ไหม?",
//         "isMe": false
//       },
//     ]
//   },
//   {
//     "chatId": "chat_2",
//     "customerName": "ต้น",
//     "customerAvatar":
//         "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=60",
//     "dogName": "ลาเต้",
//     "lastMessage": "น้องฉีดวัคซีนครบแล้วยังครับ?",
//     "time": "เมื่อวาน",
//     "unread": 0,
//     "messages": [
//       {"text": "สนใจน้องลาเต้มากเลยครับ", "isMe": false},
//       {"text": "ยินดีต้อนรับเลยครับ น้องน่ารักมาก", "isMe": true},
//       {"text": "น้องฉีดวัคซีนครบแล้วยังครับ?", "isMe": false},
//     ]
//   },
//   {
//     "chatId": "chat_3",
//     "customerName": "ฝน",
//     "customerAvatar":
//         "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=60",
//     "dogName": "ลาเต้",
//     "lastMessage": "อยากมาดูน้องก่อนได้ไหมคะ?",
//     "time": "จ. ที่แล้ว",
//     "unread": 1,
//     "messages": [
//       {
//         "text": "หวัดดีค่ะ เห็นโพสต์น้องลาเต้แล้วน่ารักมากเลยค่ะ",
//         "isMe": false
//       },
//       {"text": "ขอบคุณมากเลยครับ น้องน่ารักมากเลย 😊", "isMe": true},
//       {"text": "อยากมาดูน้องก่อนได้ไหมคะ?", "isMe": false},
//     ]
//   },
// ];

// int getTotalUnread() =>
//     mockInboxChats.fold(0, (sum, c) => sum + (c['unread'] as int));

// const List<String> thaiProvinces = [
//   'กรุงเทพมหานคร', 'กระบี่', 'กาญจนบุรี', 'กาฬสินธุ์', 'กำแพงเพชร',
//   'ขอนแก่น', 'จันทบุรี', 'ฉะเชิงเทรา', 'ชลบุรี', 'ชัยนาท',
//   'ชัยภูมิ', 'ชุมพร', 'เชียงราย', 'เชียงใหม่', 'ตรัง',
//   'ตราด', 'ตาก', 'นครนายก', 'นครปฐม', 'นครพนม',
//   'นครราชสีมา', 'นครศรีธรรมราช', 'นครสวรรค์', 'นนทบุรี', 'นราธิวาส',
//   'น่าน', 'บึงกาฬ', 'บุรีรัมย์', 'ปทุมธานี', 'ประจวบคีรีขันธ์',
//   'ปราจีนบุรี', 'ปัตตานี', 'พระนครศรีอยุธยา', 'พะเยา', 'พังงา',
//   'พัทลุง', 'พิจิตร', 'พิษณุโลก', 'เพชรบุรี', 'เพชรบูรณ์',
//   'แพร่', 'ภูเก็ต', 'มหาสารคาม', 'มุกดาหาร', 'แม่ฮ่องสอน',
//   'ยโสธร', 'ยะลา', 'ร้อยเอ็ด', 'ระนอง', 'ระยอง',
//   'ราชบุรี', 'ลพบุรี', 'ลำปาง', 'ลำพูน', 'เลย',
//   'ศรีสะเกษ', 'สกลนคร', 'สงขลา', 'สตูล', 'สมุทรปราการ',
//   'สมุทรสงคราม', 'สมุทรสาคร', 'สระแก้ว', 'สระบุรี', 'สิงห์บุรี',
//   'สุโขทัย', 'สุพรรณบุรี', 'สุราษฎร์ธานี', 'สุรินทร์', 'หนองคาย',
//   'หนองบัวลำภู', 'อ่างทอง', 'อำนาจเจริญ', 'อุดรธานี', 'อุตรดิตถ์',
//   'อุทัยธานี', 'อุบลราชธานี'
// ];

// void main() {
//   runApp(const PetPawsApp());
// }

// class PetPawsApp extends StatelessWidget {
//   const PetPawsApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'PetPaws',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB085)),
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(0xFFFFF6F0),
//       ),
//       home: const LoginScreen(),
//     );
//   }
// }

// // ==========================================
// // Part 0: Login Screen
// // ==========================================
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   void login() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const MainScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(32.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.pets, size: 100, color: Color(0xFFFF9E68)),
//               const SizedBox(height: 16),
//               const Text(
//                 'PetPaws',
//                 style: TextStyle(
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFFFF9E68)),
//               ),
//               const Text(
//                 'หาบ้านใหม่ให้สัตว์เลี้ยงแสนรัก',
//                 style: TextStyle(fontSize: 16, color: Colors.black54),
//               ),
//               const SizedBox(height: 48),
//               TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   labelText: 'อีเมล',
//                   prefixIcon:
//                       const Icon(Icons.email, color: Color(0xFFFFB085)),
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide.none),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'รหัสผ่าน',
//                   prefixIcon:
//                       const Icon(Icons.lock, color: Color(0xFFFFB085)),
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide.none),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: login,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFFF9E68),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30)),
//                     elevation: 2,
//                   ),
//                   child: const Text('เข้าสู่ระบบ',
//                       style: TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('ยังไม่มีบัญชีเหรอ? ',
//                       style: TextStyle(color: Colors.black54)),
//                   GestureDetector(
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const RegisterScreen()),
//                     ),
//                     child: const Text(
//                       'สมัครเลย',
//                       style: TextStyle(
//                           color: Color(0xFFFF9E68),
//                           fontWeight: FontWeight.bold,
//                           decoration: TextDecoration.underline),
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ==========================================
// // Part 0.5: Register Screen
// // ==========================================
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController =
//       TextEditingController();
//   String selectedProvince = 'กรุงเทพมหานคร';

//   void handleRegister() {
//     if (nameController.text.isEmpty ||
//         emailController.text.isEmpty ||
//         passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
//       return;
//     }
//     if (passwordController.text != confirmPasswordController.text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')));
//       return;
//     }
//     currentUserProfile['name'] = nameController.text;
//     currentUserProfile['email'] = emailController.text;
//     currentUserProfile['province'] = selectedProvince;
//     ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ')));
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('สมัครสมาชิก',
//             style: TextStyle(
//                 fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Color(0xFFFF9E68)),
//         elevation: 1,
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text('ข้อมูลพื้นฐานบัญชีผู้ใช้',
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFFFF9E68))),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                     labelText: 'ชื่อผู้ใช้ / ชื่อเล่น *',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                     labelText: 'อีเมล / เบอร์โทรศัพท์ *',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                     labelText: 'รหัสผ่าน *',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: confirmPasswordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                     labelText: 'ยืนยันรหัสผ่าน *',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 24),
//             const Text('ข้อมูลสถานที่',
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFFFF9E68))),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: selectedProvince,
//               decoration: InputDecoration(
//                   labelText: 'จังหวัดที่อยู่ปัจจุบัน',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16))),
//               items: thaiProvinces
//                   .map((p) => DropdownMenuItem(value: p, child: Text(p)))
//                   .toList(),
//               onChanged: (val) => setState(() => selectedProvince = val!),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: handleRegister,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFFF9E68),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30)),
//                 elevation: 2,
//               ),
//               child: const Text('สมัครสมาชิก',
//                   style:
//                       TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==========================================
// // Main Screen
// // ==========================================
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;

//   List<Map<String, dynamic>> allDogs = [
//     {
//       "id": "15",
//       "name": "เจ้านาย",
//       "breed": "Siberian Husky",
//       "province": "เชียงใหม่",
//       "age": "3 ปี",
//       "gender": "ผู้",
//       "weight": "22",
//       "temperament": "พูดเก่ง, พลังล้น, ตลก",
//       "story": "น้องชอบเถียงมากๆ ครับ ใครหาเพื่อนคุยรับรองไม่เหงาแน่นอน",
//       "imageUrl":
//           "https://placedog.net/500/500?id=15",
//       "reelUrl":
//           "https://placedog.net/500/800?id=15",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 245
//     },
//     {
//       "id": "16",
//       "name": "ชาไข่มุก",
//       "breed": "French Bulldog",
//       "province": "กรุงเทพมหานคร",
//       "age": "1 ปี",
//       "gender": "เมีย",
//       "weight": "11",
//       "temperament": "ขี้อ้อน, กินเก่ง, นอนกรน",
//       "story": "ตัวตึงประจำบ้าน ชอบนอนตากแอร์และกินขนมเป็นชีวิตจิตใจ",
//       "imageUrl":
//           "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=500&q=60",
//       "reelUrl":
//           "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=500&h=800&q=80",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 182
//     },
//     {
//       "id": "19",
//       "name": "หมูปิ้ง",
//       "breed": "Corgi",
//       "province": "นครปฐม",
//       "age": "6 เดือน",
//       "gender": "ผู้",
//       "weight": "5.5",
//       "temperament": "ขี้อ้อน, กินเก่ง, วิ่งเร็ว",
//       "story":
//           "น้องหมูปิ้งขาสั้นแต่สู้ชีวิตครับ ชอบกินขนมมากๆ พลังงานล้นเหลือ ใครหาเพื่อนวิ่งเล่นตอนเย็นๆ รับไปได้เลยครับ",
//       "imageUrl":
//           "https://images.unsplash.com/photo-1597626133663-53df9633b799?auto=format&fit=crop&w=500&q=60",
//       "reelUrl":
//           "https://images.unsplash.com/photo-1597626133663-53df9633b799?auto=format&fit=crop&w=500&h=800&q=80",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 512
//     },
//     {
//       "id": "20",
//       "name": "กะทิ",
//       "breed": "Shih Tzu",
//       "province": "ระยอง",
//       "age": "2 ปี",
//       "gender": "เมีย",
//       "weight": "4.2",
//       "temperament": "เรียบร้อย, ชอบนอน, ติดเจ้าของ",
//       "story":
//           "น้องกะทิเป็นหมาคุณหนู ชอบนอนตากแอร์ ไม่ค่อยเห่ากวนใจ นิ่งมากๆ เหมาะกับคนอยู่คอนโดหรือพื้นที่จำกัดมากๆ ค่ะ",
//       "imageUrl":
//           "https://placedog.net/500/500?id=20",
//       "reelUrl":
//           "https://placedog.net/500/800?id=20",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 89
//     },
//     {
//       "id": "12",
//       "name": "ถังหูลู่",
//       "breed": "Samoyed",
//       "province": "เชียงราย",
//       "age": "2 ปี",
//       "gender": "เมีย",
//       "weight": "18",
//       "temperament": "ยิ้มเก่ง, ขนฟู, ขี้เล่นสุดๆ",
//       "story":
//           "น้องถังหูลู่เป็นหมาอารมณ์ดี ยิ้มหวานตลอดเวลา ชอบอากาศเย็นๆ และชอบวิ่งสวนสาธารณะสุดๆ ครับ",
//       "imageUrl":
//           "https://placedog.net/500/500?id=12",
//       "reelUrl":
//           "https://placedog.net/500/800?id=12",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 310
//     },
//     {
//       "id": "1",
//       "name": "โบ้",
//       "breed": "Golden Retriever",
//       "province": "กรุงเทพมหานคร",
//       "age": "2 เดือน",
//       "gender": "ผู้",
//       "weight": "4.5",
//       "temperament": "ร่าเริง, ขี้เล่น, เป็นมิตร, กินเก่ง",
//       "story":
//           "น้องโบ้เป็นหมาน้อยวัยกำลังซน ชอบเล่นลูกบอลและชอบวิ่งเล่นในสวนสาธารณะมากๆ กำลังหาบ้านที่มีพื้นที่ให้วิ่งเล่นครับ",
//       "imageUrl":
//           "https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=500&q=60",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 140
//     },
//     {
//       "id": "21",
//       "name": "ขนมปัง",
//       "breed": "Pomeranian",
//       "province": "เชียงใหม่",
//       "age": "8 เดือน",
//       "gender": "ผู้",
//       "weight": "3.2",
//       "temperament": "ขนฟู, ขี้เล่น, ติดคนมาก",
//       "story":
//           "น้องขนมปังตัวเล็กแต่พลังเยอะ ชอบกระโดดเล่นกับเจ้าของทั้งวัน เหมาะกับคนที่อยากได้เพื่อนตัวจิ๋วไว้กอด",
//       "imageUrl":
//           "https://images.unsplash.com/photo-1612195583950-b8fd34c87093?auto=format&fit=crop&w=500&q=60",
//       "reelUrl":
//           "https://images.unsplash.com/photo-1612195583950-b8fd34c87093?auto=format&fit=crop&w=500&h=800&q=80",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 402
//     },
//     {
//       "id": "22",
//       "name": "หมีน้อย",
//       "breed": "Akita",
//       "province": "อุดรธานี",
//       "age": "1 ปี 6 เดือน",
//       "gender": "ผู้",
//       "weight": "28",
//       "temperament": "นิ่ง, ซื่อสัตย์, รักเจ้าของคนเดียว",
//       "story":
//           "น้องหมีน้อยจงรักภักดีมากครับ เหมาะกับบ้านที่มีพื้นที่กว้างและมีเวลาฝึกวินัยให้น้อง",
//       "imageUrl":
//           "https://images.unsplash.com/photo-1561037404-61cd46aa615b?auto=format&fit=crop&w=500&q=60",
//       "reelUrl":
//           "https://images.unsplash.com/photo-1561037404-61cd46aa615b?auto=format&fit=crop&w=500&h=800&q=80",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 115
//     },
//     {
//       "id": "23",
//       "name": "หวานใจ",
//       "breed": "Beagle",
//       "province": "ขอนแก่น",
//       "age": "1 ปี",
//       "gender": "เมีย",
//       "weight": "9.5",
//       "temperament": "จมูกไว, ขี้สงสัย, เห่าเก่ง",
//       "story":
//           "น้องหวานใจชอบดมกลิ่นสำรวจไปทั่ว ถ้าได้ไปเดินป่าหรือสวนสาธารณะจะมีความสุขมากๆ ค่ะ",
//       "imageUrl":
//           "https://images.unsplash.com/photo-1576201836106-db1758fd1c97?auto=format&fit=crop&w=500&q=60",
//       "reelUrl":
//           "https://images.unsplash.com/photo-1576201836106-db1758fd1c97?auto=format&fit=crop&w=500&h=800&q=80",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 260
//     },
//     {
//       "id": "24",
//       "name": "โดนัท",
//       "breed": "Pug",
//       "province": "ชลบุรี",
//       "age": "10 เดือน",
//       "gender": "ผู้",
//       "weight": "7",
//       "temperament": "ขี้เกียจ, กรนเสียงดัง, น่ารักสุดๆ",
//       "story":
//           "น้องโดนัทชอบนอนมากกว่าวิ่ง ใครอยากได้เพื่อนแบบสายชิลล์ น้องตัวนี้เลยครับ",
//       "imageUrl":
//           "https://images.unsplash.com/photo-1517849845537-4d257902861a?auto=format&fit=crop&w=500&q=60",
//       "reelUrl":
//           "https://images.unsplash.com/photo-1517849845537-4d257902861a?auto=format&fit=crop&w=500&h=800&q=80",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 380
//     },
//     {
//       "id": "25",
//       "name": "บุหงา",
//       "breed": "Shiba Inu",
//       "province": "สงขลา",
//       "age": "1 ปี 2 เดือน",
//       "gender": "เมีย",
//       "weight": "10",
//       "temperament": "หน้านิ่งใจร้าย, ฉลาด, รักความสะอาด",
//       "story":
//           "น้องบุหงาดูเฉยๆแต่จริงๆแล้วขี้อ้อนมาก ชอบนอนตากแอร์และเดินเล่นยามเย็นค่ะ",
//       "imageUrl":
//           "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=500&q=60",
//       "reelUrl":
//           "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=500&h=800&q=80",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 99
//     },
//   ];

//   List<Map<String, dynamic>> likedDogs = [];
//   List<Map<String, dynamic>> passedDogs = [];
//   List<Map<String, dynamic>> savedReels = [];
//   Set<String> engagedReelIds = {}; // เก็บ ID ของรีลที่ผู้ใช้เคยกด Like เพื่อเป็นยอดเอนเกจเมนต์

//   List<Map<String, dynamic>> myPostedDogs = [
//     {
//       "id": "my_1",
//       "name": "ลาเต้",
//       "breed": "Poodle",
//       "province": "ภูเก็ต",
//       "age": "4 เดือน",
//       "gender": "ผู้",
//       "weight": "2.5",
//       "temperament": "ขี้อ้อน, พลังล้นเหลือ",
//       "story": "กำลังหาบ้านที่พร้อมดูแลน้องลาเต้ครับ",
//       "imageUrl":
//           "https://images.unsplash.com/photo-1591160690555-5debfba289f0?auto=format&fit=crop&w=500&q=60",
//       "reelUrl":
//           "https://images.unsplash.com/photo-1591160690555-5debfba289f0?auto=format&fit=crop&w=500&h=800&q=80",
//       "status": "ยังไม่ถูกรับเลี้ยง",
//       "engagementLikes": 45
//     }
//   ];

//   void onLike(Map<String, dynamic> dog) =>
//       setState(() { likedDogs.add(dog); allDogs.remove(dog); });

//   void onPass(Map<String, dynamic> dog) =>
//       setState(() { passedDogs.add(dog); allDogs.remove(dog); });

//   void onUndoPass() {
//     if (passedDogs.isNotEmpty) {
//       setState(() {
//         allDogs.insert(0, passedDogs.removeLast());
//       });
//     }
//   }

//   void onAddDog(Map<String, dynamic> newDog) =>
//       setState(() => myPostedDogs.insert(0, newDog));

//   void onDeleteDog(Map<String, dynamic> dog) => setState(() {
//         myPostedDogs.remove(dog);
//         savedReels.removeWhere((d) => d['id'] == dog['id']);
//       });

//   void onEditDog(Map<String, dynamic> updatedDog) => setState(() {
//         final index = myPostedDogs.indexWhere((d) => d['id'] == updatedDog['id']);
//         if (index != -1) myPostedDogs[index] = updatedDog;
//       });

//   void onChangeStatus(Map<String, dynamic> dog, String newStatus) =>
//       setState(() {
//         final index = myPostedDogs.indexWhere((d) => d['id'] == dog['id']);
//         if (index != -1) myPostedDogs[index]['status'] = newStatus;
//       });

//   // ฟังก์ชันสำหรับการกดถูกใจรีล (Engagement)
//   void onLikeReel(Map<String, dynamic> dog) => setState(() {
//         final dogId = dog['id'];
//         if (engagedReelIds.contains(dogId)) {
//           engagedReelIds.remove(dogId);
//           dog['engagementLikes'] = (dog['engagementLikes'] ?? 1) - 1;
//         } else {
//           engagedReelIds.add(dogId);
//           dog['engagementLikes'] = (dog['engagementLikes'] ?? 0) + 1;
//         }
//       });

//   // ฟังก์ชันสำหรับการกดสนใจรับเลี้ยง
//   void onToggleFavoriteDog(Map<String, dynamic> dog) => setState(() {
//         final exists = likedDogs.any((d) => d['id'] == dog['id']);
//         if (exists) {
//           likedDogs.removeWhere((d) => d['id'] == dog['id']);
//         } else {
//           likedDogs.add(dog);
//           allDogs.removeWhere((d) => d['id'] == dog['id']);
//         }
//       });

//   void onToggleSaveReel(Map<String, dynamic> dog) => setState(() {
//         if (savedReels.any((d) => d['id'] == dog['id'])) {
//           savedReels.removeWhere((d) => d['id'] == dog['id']);
//         } else {
//           savedReels.add(dog);
//         }
//       });

//   @override
//   Widget build(BuildContext context) {
//     List<Map<String, dynamic>> activeReels = [...allDogs, ...myPostedDogs]
//         .where((dog) {
//           final isAvailable =
//               (dog['status'] ?? 'ยังไม่ถูกรับเลี้ยง') == 'ยังไม่ถูกรับเลี้ยง';
//           final hasReel = dog.containsKey('reelUrl') &&
//               dog['reelUrl'] != null &&
//               dog['reelUrl'].toString().trim().isNotEmpty;
//           return isAvailable && hasReel;
//         })
//         .toList();

//     final List<Widget> screens = [
//       DiscoverScreen(
//         dogs: allDogs,
//         onLike: onLike,
//         onPass: onPass,
//         onUndoPass: onUndoPass,
//         canUndo: passedDogs.isNotEmpty,
//         likedDogs: likedDogs,
//         onToggleFavorite: onToggleFavoriteDog,
//       ),
//       ReelsScreen(
//         activeReels: activeReels,
//         engagedReelIds: engagedReelIds,
//         savedReels: savedReels,
//         onLikeReel: onLikeReel,
//         onToggleSave: onToggleSaveReel,
//         myPostedDogs: myPostedDogs,
//         onGoToUpload: () => setState(() => _selectedIndex = 3),
//         likedDogs: likedDogs,
//         onToggleFavorite: onToggleFavoriteDog,
//       ),
//       FavoritesScreen(
//         likedDogs: likedDogs,
//         savedReels: savedReels,
//         onToggleSaveReel: onToggleSaveReel,
//         engagedReelIds: engagedReelIds,
//         onLikeReel: onLikeReel,
//         myPostedDogs: myPostedDogs,
//         onToggleFavorite: onToggleFavoriteDog,
//       ),
//       UploadScreen(
//         onAddDog: onAddDog,
//         myPostedDogs: myPostedDogs,
//         onDeleteDog: onDeleteDog,
//         onEditDog: onEditDog,
//         onChangeStatus: onChangeStatus,
//         likedDogs: likedDogs,
//         onToggleFavorite: onToggleFavoriteDog,
//       ),
//       const ProfileScreen(),
//     ];

//     return Scaffold(
//       body: screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) => setState(() => _selectedIndex = index),
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: const Color(0xFFFF9E68),
//         unselectedItemColor: Colors.grey.shade400,
//         backgroundColor: Colors.white,
//         items: [
//           const BottomNavigationBarItem(
//               icon: Icon(Icons.search), label: 'ค้นหา'),
//           const BottomNavigationBarItem(
//               icon: Icon(Icons.video_library), label: 'รีล'),
//           const BottomNavigationBarItem(
//               icon: Icon(Icons.favorite), label: 'ถูกใจ'),
//           const BottomNavigationBarItem(
//               icon: Icon(Icons.post_add), label: 'ลงประกาศ'),
//           // ไอคอนโปรไฟล์ + badge แจ้งเตือน unread
//           BottomNavigationBarItem(
//             label: 'โปรไฟล์',
//             icon: StatefulBuilder(
//               builder: (context, setIconState) {
//                 final unread = getTotalUnread();
//                 return Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     const Icon(Icons.person),
//                     if (unread > 0)
//                       Positioned(
//                         right: -4,
//                         top: -4,
//                         child: Container(
//                           width: 16,
//                           height: 16,
//                           decoration: const BoxDecoration(
//                             color: Colors.redAccent,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$unread',
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ==========================================
// // Part 1: Discover Screen
// // ==========================================
// class DiscoverScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> dogs;
//   final Function(Map<String, dynamic>) onLike;
//   final Function(Map<String, dynamic>) onPass;
//   final VoidCallback onUndoPass;
//   final bool canUndo;
//   final List<Map<String, dynamic>> likedDogs;
//   final Function(Map<String, dynamic>) onToggleFavorite;

//   const DiscoverScreen(
//       {super.key,
//       required this.dogs,
//       required this.onLike,
//       required this.onPass,
//       required this.onUndoPass,
//       required this.canUndo,
//       required this.likedDogs,
//       required this.onToggleFavorite});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PetPaws',
//             style: TextStyle(
//                 fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         centerTitle: true,
//       ),
//       body: dogs.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('ขอบคุณที่ทำให้สัตว์ทุกตัวมีบ้านที่อบอุ่น!',
//                       style: TextStyle(fontSize: 18, color: Colors.grey)),
//                   if (canUndo) ...[
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       onPressed: onUndoPass,
//                       icon: const Icon(Icons.replay),
//                       label: const Text('ลองดูสัตว์เลี้ยงอีกครั้ง'),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFFFB085),
//                           foregroundColor: Colors.white),
//                     )
//                   ]
//                 ],
//               ),
//             )
//           : Column(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: SwipeableCard(
//                       dog: dogs.first,
//                       onLike: () => onLike(dogs.first),
//                       onPass: () => onPass(dogs.first),
//                       likedDogs: likedDogs,
//                       onToggleFavorite: onToggleFavorite,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 24.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       FloatingActionButton(
//                         heroTag: "btn_pass",
//                         onPressed: () => onPass(dogs.first),
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.redAccent.shade200,
//                         elevation: 2,
//                         child: const Icon(Icons.close, size: 30),
//                       ),
//                       const SizedBox(width: 24),
//                       FloatingActionButton(
//                         heroTag: "btn_undo",
//                         onPressed: canUndo ? onUndoPass : null,
//                         backgroundColor:
//                             canUndo ? Colors.white : Colors.grey[200],
//                         foregroundColor: const Color(0xFFFFB085),
//                         mini: true,
//                         elevation: canUndo ? 2 : 0,
//                         child: const Icon(Icons.replay, size: 24),
//                       ),
//                       const SizedBox(width: 24),
//                       FloatingActionButton(
//                         heroTag: "btn_like",
//                         onPressed: () => onLike(dogs.first),
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.green.shade400,
//                         elevation: 2,
//                         child: const Icon(Icons.favorite, size: 30),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//     );
//   }
// }

// class SwipeableCard extends StatelessWidget {
//   final Map<String, dynamic> dog;
//   final VoidCallback onLike;
//   final VoidCallback onPass;
//   final List<Map<String, dynamic>> likedDogs;
//   final Function(Map<String, dynamic>) onToggleFavorite;

//   const SwipeableCard(
//       {super.key,
//       required this.dog,
//       required this.onLike,
//       required this.onPass,
//       required this.likedDogs,
//       required this.onToggleFavorite});

//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: Key(dog['id'].toString()),
//       onDismissed: (direction) {
//         if (direction == DismissDirection.endToStart) {
//           onPass();
//         } else if (direction == DismissDirection.startToEnd) {
//           onLike();
//         }
//       },
//       background: Container(
//         decoration: BoxDecoration(
//             color: Colors.green.shade300,
//             borderRadius: BorderRadius.circular(20)),
//         alignment: Alignment.centerLeft,
//         padding: const EdgeInsets.symmetric(horizontal: 40),
//         child: const Icon(Icons.favorite, color: Colors.white, size: 50),
//       ),
//       secondaryBackground: Container(
//         decoration: BoxDecoration(
//             color: Colors.redAccent.shade100,
//             borderRadius: BorderRadius.circular(20)),
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.symmetric(horizontal: 40),
//         child: const Icon(Icons.close, color: Colors.white, size: 50),
//       ),
//       child: GestureDetector(
//         onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => PetDetailScreen(
//                       dog: dog,
//                       isMyPost: false,
//                       isFavorited: likedDogs.any((d) => d['id'] == dog['id']),
//                       onToggleFavorite: () => onToggleFavorite(dog),
//                     ))),
//         child: Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: Colors.white,
//             boxShadow: const [
//               BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1)
//             ],
//           ),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: PetNetworkImage(
//                   imageUrl: dog['imageUrl'],
//                   fit: BoxFit.cover,
//                   iconSize: 80,
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   gradient: const LinearGradient(
//                     colors: [Colors.transparent, Colors.black87],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     stops: [0.6, 1.0],
//                   ),
//                 ),
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('${dog['name']}, ${dog['age']}',
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),
//                     Text(dog['breed'] ?? 'ไม่ระบุสายพันธุ์',
//                         style: const TextStyle(
//                             color: Colors.white70, fontSize: 18)),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(Icons.location_on,
//                             color: Color(0xFFFFB085), size: 20),
//                         const SizedBox(width: 4),
//                         Text(dog['province'],
//                             style: const TextStyle(
//                                 color: Colors.white70, fontSize: 16)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ==========================================
// // Part 1.5: Reels Screen
// // ==========================================
// class ReelsScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> activeReels;
//   final Set<String> engagedReelIds;
//   final List<Map<String, dynamic>> savedReels;
//   final Function(Map<String, dynamic>) onLikeReel;
//   final Function(Map<String, dynamic>) onToggleSave;
//   final List<Map<String, dynamic>> myPostedDogs;
//   final int initialIndex;
//   final VoidCallback onGoToUpload;
//   final List<Map<String, dynamic>> likedDogs;
//   final Function(Map<String, dynamic>) onToggleFavorite;

//   const ReelsScreen({
//     super.key,
//     required this.activeReels,
//     required this.engagedReelIds,
//     required this.savedReels,
//     required this.onLikeReel,
//     required this.onToggleSave,
//     required this.myPostedDogs,
//     required this.onGoToUpload,
//     required this.likedDogs,
//     required this.onToggleFavorite,
//     this.initialIndex = 0,
//   });

//   @override
//   State<ReelsScreen> createState() => _ReelsScreenState();
// }

// class _ReelsScreenState extends State<ReelsScreen> {
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.activeReels.isEmpty) {
//       return Scaffold(
//         backgroundColor: Colors.black,
//         appBar: Navigator.canPop(context)
//             ? AppBar(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 iconTheme: const IconThemeData(color: Colors.white))
//             : null,
//         body: const Center(
//             child: Text('ไม่มีวิดีโอในขณะนี้',
//                 style: TextStyle(color: Colors.white, fontSize: 18))),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             scrollDirection: Axis.vertical,
//             itemCount: widget.activeReels.length,
//             itemBuilder: (context, index) {
//               final dog = widget.activeReels[index];
//               final isReelLiked = widget.engagedReelIds.contains(dog['id']);
//               final isSaved =
//                   widget.savedReels.any((d) => d['id'] == dog['id']);
//               final isMyPost =
//                   widget.myPostedDogs.any((myDog) => myDog['id'] == dog['id']);

//               return Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => PetDetailScreen(
//                                   dog: dog,
//                                   isMyPost: isMyPost,
//                                   fromReels: true,
//                                   isFavorited: widget.likedDogs
//                                       .any((d) => d['id'] == dog['id']),
//                                   onToggleFavorite: () =>
//                                       widget.onToggleFavorite(dog),
//                                 ))),
//                     child: PetNetworkImage(
//                       imageUrl: dog['reelUrl'] ?? dog['imageUrl'],
//                       fit: BoxFit.cover,
//                       backgroundColor: Colors.black,
//                       iconColor: Colors.white24,
//                       iconSize: 96,
//                     ),
//                   ),
//                   Container(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.transparent, Colors.black87],
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         stops: [0.6, 1.0],
//                       ),
//                     ),
//                   ),
//                   const Center(
//                       child: Icon(Icons.play_arrow_rounded,
//                           color: Colors.white54, size: 100)),

//                   // ข้อมูลซ้ายล่าง
//                   Positioned(
//                     bottom: 20,
//                     left: 16,
//                     right: 80,
//                     child: GestureDetector(
//                       onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => PetDetailScreen(
//                                     dog: dog,
//                                     isMyPost: isMyPost,
//                                     fromReels: true,
//                                     isFavorited: widget.likedDogs
//                                         .any((d) => d['id'] == dog['id']),
//                                     onToggleFavorite: () =>
//                                         widget.onToggleFavorite(dog),
//                                   ))),
//                       child: Container(
//                         color: Colors.transparent,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 PetAvatar(
//                                   imageUrl: dog['imageUrl'],
//                                   radius: 20,
//                                   backgroundColor: Colors.white24,
//                                   iconColor: Colors.white70,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Text(dog['name'],
//                                     style: const TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 22)),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             Text(
//                                 'พิกัด: ${dog['province']} • สายพันธุ์: ${dog['breed']}',
//                                 style: const TextStyle(
//                                     color: Colors.white70, fontSize: 14)),
//                             const SizedBox(height: 8),
//                             Text(dog['story'],
//                                 style: const TextStyle(
//                                     color: Colors.white, fontSize: 14),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ปุ่มขวาล่าง
//                   Positioned(
//                     bottom: 20,
//                     right: 12,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         _buildActionItem(
//                           icon: Icons.person,
//                           label: 'Profile',
//                           color: Colors.white,
//                           onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => PetDetailScreen(
//                                         dog: dog,
//                                         isMyPost: isMyPost,
//                                         fromReels: true,
//                                         isFavorited: widget.likedDogs
//                                             .any((d) => d['id'] == dog['id']),
//                                         onToggleFavorite: () =>
//                                             widget.onToggleFavorite(dog),
//                                       ))),
//                         ),
//                         if (!isMyPost) ...[
//                           _buildActionItem(
//                             icon: isReelLiked
//                                 ? Icons.favorite
//                                 : Icons.favorite_border,
//                             label: 'Like',
//                             color:
//                                 isReelLiked ? Colors.redAccent : Colors.white,
//                             onTap: () {
//                               widget.onLikeReel(dog);
//                               setState(() {});
//                               ScaffoldMessenger.of(context).clearSnackBars();
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(isReelLiked
//                                       ? 'เลิกถูกใจวิดีโอแล้ว'
//                                       : 'ถูกใจวิดีโอนี้แล้ว'),
//                                   duration: const Duration(seconds: 1),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildActionItem(
//                             icon: isSaved
//                                 ? Icons.bookmark
//                                 : Icons.bookmark_border,
//                             label: 'Save',
//                             color: isSaved
//                                 ? const Color(0xFFFF9E68)
//                                 : Colors.white,
//                             onTap: () {
//                               widget.onToggleSave(dog);
//                               setState(() {});
//                               ScaffoldMessenger.of(context).clearSnackBars();
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(isSaved
//                                       ? 'เลิกบันทึกวิดีโอแล้ว'
//                                       : 'บันทึกวิดีโอแล้ว'),
//                                   duration: const Duration(seconds: 1),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//           if (Navigator.canPop(context))
//             Positioned(
//               top: 40,
//               left: 8,
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_back,
//                     color: Colors.white, size: 30),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//           if (!Navigator.canPop(context))
//             Positioned(
//               top: 40,
//               right: 16,
//               child: GestureDetector(
//                 onTap: widget.onGoToUpload,
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.black45,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.white70, width: 1.5),
//                   ),
//                   child: const Row(
//                     children: [
//                       Icon(Icons.add, color: Colors.white, size: 20),
//                       SizedBox(width: 4),
//                       Text('เพิ่มรีล',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionItem(
//       {required IconData icon,
//       required String label,
//       required Color color,
//       required VoidCallback onTap}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: InkWell(
//         onTap: onTap,
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 36),
//             const SizedBox(height: 4),
//             Text(label,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==========================================
// // Part 2: Favorites Screen
// // ==========================================
// class FavoritesScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> likedDogs;
//   final List<Map<String, dynamic>> savedReels;
//   final Function(Map<String, dynamic>) onToggleSaveReel;
//   final Function(Map<String, dynamic>) onLikeReel;
//   final Set<String> engagedReelIds;
//   final List<Map<String, dynamic>> myPostedDogs;
//   final Function(Map<String, dynamic>) onToggleFavorite;

//   const FavoritesScreen({
//     super.key,
//     required this.likedDogs,
//     required this.savedReels,
//     required this.onToggleSaveReel,
//     required this.onLikeReel,
//     required this.engagedReelIds,
//     required this.myPostedDogs,
//     required this.onToggleFavorite,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('รายการที่สนใจ',
//               style: TextStyle(
//                   fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
//           backgroundColor: Colors.white,
//           elevation: 1,
//           centerTitle: true,
//           bottom: const TabBar(
//             labelColor: Color(0xFFFF9E68),
//             unselectedLabelColor: Colors.grey,
//             indicatorColor: Color(0xFFFF9E68),
//             tabs: [
//               Tab(icon: Icon(Icons.thumb_up), text: "สัตว์เลี้ยงที่ถูกใจ"),
//               Tab(icon: Icon(Icons.video_library), text: "รีลที่บันทึก"),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             likedDogs.isEmpty
//                 ? const Center(
//                     child: Text('ยังไม่มีสัตว์เลี้ยงที่ถูกใจเลย',
//                         style: TextStyle(fontSize: 16, color: Colors.grey)))
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(12),
//                     itemCount: likedDogs.length,
//                     itemBuilder: (context, index) {
//                       final dog = likedDogs[index];
//                       return Card(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         elevation: 1,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16)),
//                         child: ListTile(
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 8),
//                           leading: PetAvatar(
//                             imageUrl: dog['imageUrl'],
//                             radius: 30,
//                           ),
//                           title: Text(dog['name'],
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold)),
//                           subtitle:
//                               Text('${dog['province']} • ${dog['breed']}'),
//                           trailing: ElevatedButton.icon(
//                             onPressed: () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => ChatScreen(
//                                         dogName: dog['name'],
//                                         isOwnerMode: false))),
//                             icon: const Icon(Icons.chat, size: 18),
//                             label: const Text('ทักแชท'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFFFB085),
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                             ),
//                           ),
//                           onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => PetDetailScreen(
//                                         dog: dog,
//                                         isMyPost: false,
//                                         isFavorited: likedDogs
//                                             .any((d) => d['id'] == dog['id']),
//                                         onToggleFavorite: () =>
//                                             onToggleFavorite(dog),
//                                       ))),
//                         ),
//                       );
//                     },
//                   ),
//             savedReels.isEmpty
//                 ? const Center(
//                     child: Text('ยังไม่ได้บันทึกวิดีโอใดๆ',
//                         style: TextStyle(fontSize: 16, color: Colors.grey)))
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(12),
//                     itemCount: savedReels.length,
//                     itemBuilder: (context, index) {
//                       final dog = savedReels[index];
//                       final isReelLiked = engagedReelIds.contains(dog['id']);
//                       final isSaved =
//                           savedReels.any((d) => d['id'] == dog['id']);
//                       return Card(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         elevation: 1,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16)),
//                         child: Column(
//                           children: [
//                             GestureDetector(
//                               onTap: () => Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => ReelsScreen(
//                                             activeReels: savedReels,
//                                             engagedReelIds: engagedReelIds,
//                                             savedReels: savedReels,
//                                             onLikeReel: onLikeReel,
//                                             onToggleSave: onToggleSaveReel,
//                                             myPostedDogs: myPostedDogs,
//                                             onGoToUpload: () {},
//                                             initialIndex: index,
//                                             likedDogs: likedDogs,
//                                             onToggleFavorite: onToggleFavorite,
//                                           ))),
//                               child: ClipRRect(
//                                 borderRadius: const BorderRadius.vertical(
//                                     top: Radius.circular(16)),
//                                 child: SizedBox(
//                                   height: 200,
//                                   width: double.infinity,
//                                   child: Stack(
//                                     fit: StackFit.expand,
//                                     children: [
//                                       PetNetworkImage(
//                                         imageUrl:
//                                             dog['reelUrl'] ?? dog['imageUrl'],
//                                         fit: BoxFit.cover,
//                                       ),
//                                       const Center(
//                                           child: Icon(Icons.play_circle_outline,
//                                               color: Colors.white70, size: 50)),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             ListTile(
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 8),
//                               leading: PetAvatar(imageUrl: dog['imageUrl']),
//                               title: Text('วิดีโอของ ${dog['name']}',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold)),
//                               subtitle: const Text(
//                                   'กดเพื่อดูโปรไฟล์ และเตรียมรับเลี้ยง',
//                                   style: TextStyle(fontSize: 12)),
//                               trailing: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   IconButton(
//                                     onPressed: () => onLikeReel(dog),
//                                     icon: Icon(
//                                         isReelLiked
//                                             ? Icons.favorite
//                                             : Icons.favorite_border,
//                                         color: Colors.redAccent,
//                                         size: 28),
//                                   ),
//                                   IconButton(
//                                     onPressed: () => onToggleSaveReel(dog),
//                                     icon: Icon(
//                                         isSaved
//                                             ? Icons.bookmark
//                                             : Icons.bookmark_border,
//                                         color: const Color(0xFFFF9E68),
//                                         size: 28),
//                                   ),
//                                 ],
//                               ),
//                               onTap: () => Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => PetDetailScreen(
//                                             dog: dog,
//                                             isMyPost: myPostedDogs.any(
//                                                 (myDog) =>
//                                                     myDog['id'] ==
//                                                     dog['id']),
//                                             isFavorited: likedDogs.any(
//                                                 (d) => d['id'] == dog['id']),
//                                             onToggleFavorite: () =>
//                                                 onToggleFavorite(dog),
//                                           ))),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==========================================
// // Part 3: Upload Screen
// // ==========================================
// class UploadScreen extends StatefulWidget {
//   final Function(Map<String, dynamic>) onAddDog;
//   final Function(Map<String, dynamic>) onDeleteDog;
//   final Function(Map<String, dynamic>) onEditDog;
//   final Function(Map<String, dynamic>, String) onChangeStatus;
//   final List<Map<String, dynamic>> myPostedDogs;
//   final List<Map<String, dynamic>> likedDogs;
//   final Function(Map<String, dynamic>) onToggleFavorite;

//   const UploadScreen(
//       {super.key,
//       required this.onAddDog,
//       required this.myPostedDogs,
//       required this.onDeleteDog,
//       required this.onChangeStatus,
//       required this.onEditDog,
//       required this.likedDogs,
//       required this.onToggleFavorite});

//   @override
//   State<UploadScreen> createState() => _UploadScreenState();
// }

// class _UploadScreenState extends State<UploadScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController breedController = TextEditingController();
//   final TextEditingController ageController = TextEditingController();
//   final TextEditingController weightController = TextEditingController();
//   final TextEditingController temperamentController = TextEditingController();
//   final TextEditingController storyController = TextEditingController();
//   final TextEditingController imageController = TextEditingController();
//   final TextEditingController reelController = TextEditingController();

//   String selectedProvince = 'กรุงเทพมหานคร';
//   String selectedGender = 'ผู้';
//   final List<String> genders = ['ผู้', 'เมีย'];

//   void submitForm() {
//     if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
//       final newDog = {
//         "id": DateTime.now().millisecondsSinceEpoch.toString(),
//         "name": nameController.text,
//         "breed":
//             breedController.text.isEmpty ? "พันทาง" : breedController.text,
//         "province": selectedProvince,
//         "age": ageController.text,
//         "gender": selectedGender,
//         "weight": weightController.text.isEmpty ? "-" : weightController.text,
//         "temperament": temperamentController.text.isEmpty
//             ? "น่ารัก เป็นมิตร"
//             : temperamentController.text,
//         "story": storyController.text.isEmpty
//             ? "กำลังรอคนใจดีมารับไปดูแลอยู่ครับ/ค่ะ"
//             : storyController.text,
//         "imageUrl": imageController.text.isNotEmpty
//             ? imageController.text
//             : "https://images.unsplash.com/photo-1543852786-1cf6624b9987?auto=format&fit=crop&w=400&q=60",
//         "reelUrl": reelController.text,
//         "status": "ยังไม่ถูกรับเลี้ยง",
//         "engagementLikes": 0 // เพิ่มค่าเริ่มต้นให้กับโพสต์ใหม่
//       };
//       widget.onAddDog(newDog);
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('ประกาศหาบ้านสำเร็จ!')));
//       nameController.clear();
//       breedController.clear();
//       ageController.clear();
//       weightController.clear();
//       temperamentController.clear();
//       storyController.clear();
//       imageController.clear();
//       reelController.clear();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('กรุณากรอกชื่อและอายุ')));
//     }
//   }

//   Color _getStatusColor(String status) {
//     if (status == 'ถูกรับเลี้ยงแล้ว') return Colors.green.shade400;
//     if (status == 'ยกเลิกประกาศ') return Colors.redAccent.shade200;
//     return const Color(0xFFFF9E68);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('ลงประกาศ / อัปโหลดรีล',
//             style: TextStyle(
//                 fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                     labelText: 'ชื่อน้องหมา *',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: breedController,
//                 decoration: InputDecoration(
//                     labelText: 'สายพันธุ์',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                     child: TextField(
//                         controller: ageController,
//                         decoration: InputDecoration(
//                             labelText: 'อายุ *',
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16))))),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: selectedGender,
//                     decoration: InputDecoration(
//                         labelText: 'เพศ',
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16))),
//                     items: genders
//                         .map((g) =>
//                             DropdownMenuItem(value: g, child: Text(g)))
//                         .toList(),
//                     onChanged: (val) =>
//                         setState(() => selectedGender = val!),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: selectedProvince,
//                     decoration: InputDecoration(
//                         labelText: 'จังหวัด',
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16))),
//                     items: thaiProvinces
//                         .map((p) =>
//                             DropdownMenuItem(value: p, child: Text(p)))
//                         .toList(),
//                     onChanged: (val) =>
//                         setState(() => selectedProvince = val!),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                     child: TextField(
//                         controller: weightController,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                             labelText: 'น้ำหนัก (กก.)',
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16))))),
//               ],
//             ),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: temperamentController,
//                 decoration: InputDecoration(
//                     labelText: 'นิสัยเด่นๆ',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: storyController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                     labelText: 'รายละเอียดเพิ่มเติม / เรื่องราวของน้อง',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 16),
//             const Text('รูปภาพและวิดีโอ',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87)),
//             const SizedBox(height: 8),
//             TextField(
//                 controller: imageController,
//                 decoration: InputDecoration(
//                     labelText: 'URL รูปภาพโปรไฟล์น้องหมา',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     prefixIcon: const Icon(Icons.image))),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: reelController,
//                 decoration: InputDecoration(
//                     labelText:
//                         'URL วิดีโอรีล (ถ้ามีคลิปจะไปโผล่ในหน้ารีล)',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     prefixIcon: const Icon(Icons.video_library))),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: submitForm,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFFF9E68),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30)),
//                 elevation: 2,
//               ),
//               child: const Text('โพสต์หาบ้าน',
//                   style:
//                       TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
//             const SizedBox(height: 32),
//             const Divider(color: Colors.black12),
//             const SizedBox(height: 16),
//             const Text('ประกาศ / รีล ของฉัน',
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFFFF9E68))),
//             const SizedBox(height: 12),
//             widget.myPostedDogs.isEmpty
//                 ? const Text('คุณยังไม่ได้ลงประกาศสัตว์เลี้ยง',
//                     style: TextStyle(color: Colors.grey))
//                 : ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: widget.myPostedDogs.length,
//                     itemBuilder: (context, index) {
//                       final dog = widget.myPostedDogs[index];
//                       final currentStatus =
//                           dog['status'] ?? 'ยังไม่ถูกรับเลี้ยง';
//                       return Card(
//                         elevation: 0,
//                         color: const Color(0xFFFFF6F0),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                             side: BorderSide(
//                                 color: Colors.orange.shade100, width: 1)),
//                         margin: const EdgeInsets.only(bottom: 16),
//                         child: InkWell(
//                           onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => PetDetailScreen(
//                                         dog: dog,
//                                         isMyPost: true,
//                                         isFavorited: widget.likedDogs.any((d) => d['id'] == dog['id']),
//                                         onToggleFavorite: () => widget.onToggleFavorite(dog),
//                                       ))),
//                           borderRadius: BorderRadius.circular(20),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   leading: PetAvatar(
//                                     imageUrl: dog['imageUrl'],
//                                     radius: 28,
//                                   ),
//                                   title: Text(dog['name'],
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 18,
//                                           color: Color(0xFFFF9E68))),
//                                   subtitle: Text(
//                                       '${dog['province']} • อายุ ${dog['age']}'),
//                                   trailing: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       IconButton(
//                                         icon: const Icon(Icons.edit,
//                                             color: Colors.blueGrey),
//                                         onPressed: () => Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     EditDogScreen(
//                                                         dog: dog,
//                                                         onSave: widget
//                                                             .onEditDog))),
//                                       ),
//                                       IconButton(
//                                         icon: const Icon(
//                                             Icons.delete_outline,
//                                             color: Colors.redAccent),
//                                         onPressed: () {
//                                           widget.onDeleteDog(dog);
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(const SnackBar(
//                                                   content: Text(
//                                                       'ลบประกาศเรียบร้อยแล้ว')));
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 if (dog['reelUrl'] != null &&
//                                     dog['reelUrl'].toString().isNotEmpty)
//                                   const Padding(
//                                     padding: EdgeInsets.only(bottom: 8.0),
//                                     child: Row(
//                                       children: [
//                                         Icon(Icons.video_library,
//                                             size: 14, color: Colors.black54),
//                                         SizedBox(width: 4),
//                                         Text('มีวิดีโอรีล',
//                                             style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: Colors.black54)),
//                                       ],
//                                     ),
//                                   ),
//                                 const Divider(color: Colors.white),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     const Text('สถานะปัจจุบัน:',
//                                         style:
//                                             TextStyle(color: Colors.black54)),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 12, vertical: 4),
//                                       decoration: BoxDecoration(
//                                         color: _getStatusColor(currentStatus)
//                                             .withOpacity(0.15),
//                                         borderRadius:
//                                             BorderRadius.circular(20),
//                                       ),
//                                       child: DropdownButton<String>(
//                                         value: currentStatus,
//                                         underline: const SizedBox(),
//                                         icon: Icon(Icons.arrow_drop_down,
//                                             color: _getStatusColor(
//                                                 currentStatus)),
//                                         style: TextStyle(
//                                           color:
//                                               _getStatusColor(currentStatus),
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: 'Roboto',
//                                         ),
//                                         items: [
//                                           'ยังไม่ถูกรับเลี้ยง',
//                                           'ถูกรับเลี้ยงแล้ว',
//                                           'ยกเลิกประกาศ'
//                                         ]
//                                             .map((statusText) =>
//                                                 DropdownMenuItem(
//                                                     value: statusText,
//                                                     child: Text(statusText)))
//                                             .toList(),
//                                         onChanged: (newValue) {
//                                           if (newValue != null) {
//                                             widget.onChangeStatus(
//                                                 dog, newValue);
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==========================================
// // Part 3.1: Edit Screen
// // ==========================================
// class EditDogScreen extends StatefulWidget {
//   final Map<String, dynamic> dog;
//   final Function(Map<String, dynamic>) onSave;

//   const EditDogScreen({super.key, required this.dog, required this.onSave});

//   @override
//   State<EditDogScreen> createState() => _EditDogScreenState();
// }

// class _EditDogScreenState extends State<EditDogScreen> {
//   late TextEditingController nameController;
//   late TextEditingController breedController;
//   late TextEditingController ageController;
//   late TextEditingController weightController;
//   late TextEditingController temperamentController;
//   late TextEditingController storyController;
//   late TextEditingController imageController;
//   late TextEditingController reelController;

//   late String selectedProvince;
//   late String selectedGender;
//   final List<String> genders = ['ผู้', 'เมีย'];

//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.dog['name']);
//     breedController = TextEditingController(text: widget.dog['breed']);
//     ageController = TextEditingController(text: widget.dog['age']);
//     weightController = TextEditingController(text: widget.dog['weight']);
//     temperamentController =
//         TextEditingController(text: widget.dog['temperament']);
//     storyController = TextEditingController(text: widget.dog['story']);
//     imageController = TextEditingController(text: widget.dog['imageUrl']);
//     reelController =
//         TextEditingController(text: widget.dog['reelUrl'] ?? '');
//     selectedProvince =
//         thaiProvinces.contains(widget.dog['province'])
//             ? widget.dog['province']
//             : 'กรุงเทพมหานคร';
//     selectedGender =
//         genders.contains(widget.dog['gender']) ? widget.dog['gender'] : 'ผู้';
//   }

//   void saveChanges() {
//     if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
//       final updatedDog = {
//         "id": widget.dog['id'],
//         "name": nameController.text,
//         "breed":
//             breedController.text.isEmpty ? "พันทาง" : breedController.text,
//         "province": selectedProvince,
//         "age": ageController.text,
//         "gender": selectedGender,
//         "weight": weightController.text.isEmpty ? "-" : weightController.text,
//         "temperament": temperamentController.text.isEmpty
//             ? "น่ารัก เป็นมิตร"
//             : temperamentController.text,
//         "story": storyController.text.isEmpty
//             ? "ไม่มีข้อมูล"
//             : storyController.text,
//         "imageUrl": imageController.text.isNotEmpty
//             ? imageController.text
//             : "https://images.unsplash.com/photo-1543852786-1cf6624b9987?auto=format&fit=crop&w=400&q=60",
//         "reelUrl": reelController.text,
//         "status": widget.dog['status'],
//         "engagementLikes": widget.dog['engagementLikes'] ?? 0,
//       };
//       widget.onSave(updatedDog);
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('อัปเดตข้อมูลสำเร็จ!')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('แก้ไขข้อมูล',
//             style: TextStyle(
//                 fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Color(0xFFFF9E68)),
//         elevation: 1,
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                     labelText: 'ชื่อน้องหมา *',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: breedController,
//                 decoration: InputDecoration(
//                     labelText: 'สายพันธุ์',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 16),
//             Row(children: [
//               Expanded(
//                   child: TextField(
//                       controller: ageController,
//                       decoration: InputDecoration(
//                           labelText: 'อายุ *',
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16))))),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: selectedGender,
//                   decoration: InputDecoration(
//                       labelText: 'เพศ',
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16))),
//                   items: genders
//                       .map((g) =>
//                           DropdownMenuItem(value: g, child: Text(g)))
//                       .toList(),
//                   onChanged: (val) => setState(() => selectedGender = val!),
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 16),
//             Row(children: [
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: selectedProvince,
//                   decoration: InputDecoration(
//                       labelText: 'จังหวัด',
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16))),
//                   items: thaiProvinces
//                       .map((p) =>
//                           DropdownMenuItem(value: p, child: Text(p)))
//                       .toList(),
//                   onChanged: (val) =>
//                       setState(() => selectedProvince = val!),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                   child: TextField(
//                       controller: weightController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                           labelText: 'น้ำหนัก (กก.)',
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16))))),
//             ]),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: temperamentController,
//                 decoration: InputDecoration(
//                     labelText: 'นิสัยเด่นๆ',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: storyController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                     labelText: 'รายละเอียดเพิ่มเติม / เรื่องราวของน้อง',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)))),
//             const SizedBox(height: 16),
//             const Text('รูปภาพและวิดีโอ',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87)),
//             const SizedBox(height: 8),
//             TextField(
//                 controller: imageController,
//                 decoration: InputDecoration(
//                     labelText: 'URL รูปภาพโปรไฟล์น้องหมา',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     prefixIcon: const Icon(Icons.image))),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: reelController,
//                 decoration: InputDecoration(
//                     labelText: 'URL วิดีโอรีล (เว้นว่างได้ถ้าไม่มี)',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     prefixIcon: const Icon(Icons.video_library))),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: saveChanges,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueGrey.shade400,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30)),
//               ),
//               child: const Text('บันทึกการแก้ไข',
//                   style:
//                       TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==========================================
// // Part 4: Pet Detail Screen
// // ==========================================
// class PetDetailScreen extends StatefulWidget {
//   final Map<String, dynamic> dog;
//   final bool isMyPost;
//   final bool fromReels;
//   final bool isFavorited;
//   final VoidCallback? onToggleFavorite;

//   const PetDetailScreen({
//     super.key,
//     required this.dog,
//     this.isMyPost = false,
//     this.fromReels = false,
//     this.isFavorited = false,
//     this.onToggleFavorite,
//   });

//   @override
//   State<PetDetailScreen> createState() => _PetDetailScreenState();
// }

// class _PetDetailScreenState extends State<PetDetailScreen> {
//   late bool _isFavorited;

//   @override
//   void initState() {
//     super.initState();
//     _isFavorited = widget.isFavorited;
//   }

//   void _handleToggleFavorite() {
//     setState(() {
//       _isFavorited = !_isFavorited;
//     });
//     widget.onToggleFavorite?.call();
    
//     // แสดง SnackBar
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(_isFavorited ? 'บันทึกเป็นสัตว์เลี้ยงที่ถูกใจแล้ว' : 'เลิกถูกใจสัตว์เลี้ยงแล้ว'),
//         duration: const Duration(seconds: 1),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           iconTheme: const IconThemeData(color: Colors.white)),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             PetNetworkImage(
//               imageUrl: widget.dog['imageUrl'],
//               width: double.infinity,
//               height: 400,
//               fit: BoxFit.cover,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(widget.dog['name'],
//                           style: const TextStyle(
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFFFF9E68))),
//                       Icon(
//                           widget.dog['gender'] == 'ผู้'
//                               ? Icons.male
//                               : Icons.female,
//                           size: 32,
//                           color: widget.dog['gender'] == 'ผู้'
//                               ? Colors.blue.shade300
//                               : Colors.pink.shade300),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(Icons.location_on,
//                               color: Color(0xFFFFB085)),
//                           const SizedBox(width: 8),
//                           Text(widget.dog['province'],
//                               style: TextStyle(
//                                   fontSize: 18, color: Colors.grey[700])),
//                         ],
//                       ),
//                       if (widget.dog['engagementLikes'] != null)
//                         Row(
//                           children: [
//                             const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
//                             const SizedBox(width: 4),
//                             Text('${widget.dog['engagementLikes']} ไลก์รีล',
//                                 style: const TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
//                           ],
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   Row(
//                     children: [
//                       _buildInfoCard(
//                           Icons.pets, 'สายพันธุ์', widget.dog['breed'] ?? 'ไม่ระบุ'),
//                       const SizedBox(width: 16),
//                       _buildInfoCard(Icons.cake, 'อายุ', widget.dog['age']),
//                       const SizedBox(width: 16),
//                       _buildInfoCard(Icons.monitor_weight, 'น้ำหนัก',
//                           '${widget.dog['weight'] ?? '-'} กก.'),
//                     ],
//                   ),
//                   const SizedBox(height: 32),
//                   const Text('ลักษณะนิสัย',
//                       style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87)),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8.0,
//                     runSpacing: 8.0,
//                     children:
//                         (widget.dog['temperament'] as String? ?? 'ไม่ระบุ')
//                             .split(',')
//                             .map((temp) {
//                       return Chip(
//                         label: Text(temp.trim(),
//                             style: const TextStyle(
//                                 color: Color(0xFFFF9E68),
//                                 fontWeight: FontWeight.bold)),
//                         backgroundColor: const Color(0xFFFFF6F0),
//                         side: BorderSide.none,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20)),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 32),
//                   const Text('เกี่ยวกับฉัน',
//                       style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87)),
//                   const SizedBox(height: 12),
//                   Text(widget.dog['story'] ?? 'ยังไม่มีข้อมูลเพิ่มเติม',
//                       style: const TextStyle(
//                           fontSize: 16,
//                           height: 1.5,
//                           color: Colors.black87)),
//                   const SizedBox(height: 40),

//                   // ===== ปุ่มด้านล่าง =====
//                   if (widget.isMyPost)
//                     // เจ้าของโพสต์ → กดดู inbox แชท
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 ChatInboxScreen(dogName: widget.dog['name']),
//                           ),
//                         ),
//                         icon: const Icon(Icons.forum),
//                         label: const Text(
//                           'ดูแชทจากผู้สนใจรับเลี้ยง',
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFFF9E68),
//                           foregroundColor: Colors.white,
//                           padding:
//                               const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30)),
//                           elevation: 2,
//                         ),
//                       ),
//                     )
//                   else
//                     // คนอื่น → กดสนใจรับเลี้ยง + ทักแชท
//                     Row(
//                       children: [
//                         // ปุ่ม สนใจ (Favorite)
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: const Color(0xFFFF9E68), width: 2),
//                             shape: BoxShape.circle,
//                             color: _isFavorited ? const Color(0xFFFF9E68).withOpacity(0.1) : Colors.white,
//                           ),
//                           child: IconButton(
//                             iconSize: 32,
//                             icon: Icon(
//                               _isFavorited ? Icons.favorite : Icons.favorite_border,
//                               color: _isFavorited ? Colors.redAccent : const Color(0xFFFF9E68),
//                             ),
//                             onPressed: _handleToggleFavorite,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         // ปุ่ม ทักแชท
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ChatScreen(
//                                   dogName: widget.dog['name'],
//                                   isOwnerMode: false,
//                                 ),
//                               ),
//                             ),
//                             icon: const Icon(Icons.chat),
//                             label: const Text(
//                               'ทักแชทเจ้าของ',
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFFF9E68),
//                               foregroundColor: Colors.white,
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30)),
//                               elevation: 2,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(IconData icon, String title, String value) {
//     return Expanded(
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//         decoration: BoxDecoration(
//             color: const Color(0xFFFFF6F0),
//             borderRadius: BorderRadius.circular(16)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Icon(icon, color: const Color(0xFFFFB085)),
//             const SizedBox(height: 8),
//             Text(title,
//                 style: const TextStyle(
//                     color: Colors.black54, fontSize: 14)),
//             const SizedBox(height: 4),
//             Text(value,
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: Color(0xFFFF9E68)),
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==========================================
// // Part 4.5: User Profile Screen
// // ==========================================
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   bool _isEditing = false;

//   final TextEditingController phoneController =
//       TextEditingController(text: currentUserProfile['phone']);
//   final TextEditingController lineController =
//       TextEditingController(text: currentUserProfile['lineId']);
//   final TextEditingController fbController =
//       TextEditingController(text: currentUserProfile['fbLink']);

//   String currentHomeType = currentUserProfile['homeType'];
//   String currentRole = currentUserProfile['role'];

//   final List<String> homeTypes = [
//     'บ้านเดี่ยว',
//     'ทาวน์โฮม/ทาวน์เฮ้าส์',
//     'คอนโดมิเนียม',
//     'อพาร์ทเม้นท์/ห้องเช่า'
//   ];
//   final List<String> roles = [
//     'ฉันอยากหาหมาไปเลี้ยง (Adopter)',
//     'ฉันมีน้องหมาอยากหาบ้านให้ (Owner/Shelter)'
//   ];

//   final List<String> availableTraits = [
//     'สายลุย', 'สายชิล', 'ชอบอยู่บ้าน', 'ชอบวิ่งเล่น',
//     'รักเด็ก', 'ติดคน', 'รักความสงบ', 'สายสปอร์ต'
//   ];
//   late List<String> selectedTraits;

//   @override
//   void initState() {
//     super.initState();
//     selectedTraits =
//         List<String>.from(currentUserProfile['traits'] ?? []);
//   }

//   void toggleTrait(String trait) {
//     if (!_isEditing) return;
//     setState(() {
//       if (selectedTraits.contains(trait)) {
//         selectedTraits.remove(trait);
//       } else {
//         selectedTraits.add(trait);
//       }
//     });
//   }

//   void saveProfileData() {
//     setState(() {
//       currentUserProfile['phone'] = phoneController.text;
//       currentUserProfile['lineId'] = lineController.text;
//       currentUserProfile['fbLink'] = fbController.text;
//       currentUserProfile['homeType'] = currentHomeType;
//       currentUserProfile['role'] = currentRole;
//       currentUserProfile['traits'] = selectedTraits;
//       _isEditing = false;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('บันทึกข้อมูลโปรไฟล์เรียบร้อยแล้ว!'),
//         duration: Duration(seconds: 2)));
//   }

//   void startEditing() {
//     setState(() {
//       _isEditing = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // นับ unread ทั้งหมด
//     final totalUnread = getTotalUnread();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('โปรไฟล์ของฉัน',
//             style: TextStyle(
//                 fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         centerTitle: true,
//         // badge แจ้งเตือนแชทที่ AppBar
//         actions: [
//           if (totalUnread > 0)
//             Padding(
//               padding: const EdgeInsets.only(right: 12.0),
//               child: GestureDetector(
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         const ChatInboxScreen(dogName: 'ลาเต้'),
//                   ),
//                 ),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     const Icon(Icons.notifications,
//                         color: Color(0xFFFF9E68), size: 28),
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: Container(
//                         width: 16,
//                         height: 16,
//                         decoration: const BoxDecoration(
//                           color: Colors.redAccent,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(
//                             '$totalUnread',
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 PetAvatar(
//                   imageUrl: currentUserProfile['profileImageUrl'],
//                   radius: 60,
//                   icon: Icons.person,
//                 ),
//                 if (_isEditing)
//                   GestureDetector(
//                     onTap: () => ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content:
//                               Text('กำลังเปิดแกลเลอรี่เพื่อเลือกรูปภาพ...'),
//                           duration: Duration(seconds: 2))),
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFF9E68),
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.white, width: 2),
//                       ),
//                       child: const Icon(Icons.camera_alt,
//                           color: Colors.white, size: 20),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(currentUserProfile['name'],
//                 style: const TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFFFF9E68))),
//             Text(currentUserProfile['email'],
//                 style:
//                     const TextStyle(fontSize: 14, color: Colors.black54)),
//             Chip(
//               avatar: const Icon(Icons.location_on,
//                   color: Colors.white, size: 16),
//               label: Text(currentUserProfile['province'],
//                   style: const TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.bold)),
//               backgroundColor: const Color(0xFFFFB085),
//               side: BorderSide.none,
//             ),

//             // ===== แบนเนอร์แชทรอการตอบกลับ =====
//             if (totalUnread > 0) ...[
//               const SizedBox(height: 16),
//               GestureDetector(
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         const ChatInboxScreen(dogName: 'ลาเต้'),
//                   ),
//                 ),
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 14),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFF9E68).withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                         color: const Color(0xFFFF9E68).withOpacity(0.4),
//                         width: 1.5),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: const BoxDecoration(
//                           color: Color(0xFFFF9E68),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(Icons.chat,
//                             color: Colors.white, size: 20),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'มีข้อความใหม่ $totalUnread ข้อความ',
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 15,
//                                   color: Color(0xFFFF9E68)),
//                             ),
//                             const Text(
//                               'มีคนสนใจรับเลี้ยงน้องของคุณ กดเพื่อดูแชท',
//                               style: TextStyle(
//                                   fontSize: 12, color: Colors.black54),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Icon(Icons.chevron_right,
//                           color: Color(0xFFFF9E68)),
//                     ],
//                   ),
//                 ),
//               ),
//             ],

//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 16.0),
//               child: Divider(color: Colors.black12),
//             ),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'ไลฟ์สไตล์ / นิสัยของคุณ',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 8.0,
//               runSpacing: 4.0,
//               alignment: WrapAlignment.start,
//               children: availableTraits.map((trait) {
//                 final isSelected = selectedTraits.contains(trait);
//                 return ChoiceChip(
//                   label: Text(trait,
//                       style: TextStyle(
//                           color: isSelected ? Colors.white : Colors.black87,
//                           fontWeight: isSelected
//                               ? FontWeight.bold
//                               : FontWeight.normal)),
//                   selected: isSelected,
//                   onSelected:
//                       _isEditing ? (selected) => toggleTrait(trait) : null,
//                   selectedColor: const Color(0xFFFF9E68),
//                   backgroundColor: const Color(0xFFFFF6F0),
//                   disabledColor: isSelected
//                       ? const Color(0xFFFF9E68).withOpacity(0.65)
//                       : const Color(0xFFFFF6F0),
//                   side: BorderSide.none,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20)),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 24),
//             const Divider(color: Colors.black12),
//             const SizedBox(height: 8),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'ข้อมูลการติดต่อ',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: phoneController,
//               enabled: _isEditing,
//               keyboardType: TextInputType.phone,
//               decoration: InputDecoration(
//                   labelText: 'เบอร์โทรศัพท์',
//                   prefixIcon: const Icon(Icons.phone),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16))),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: lineController,
//               enabled: _isEditing,
//               decoration: InputDecoration(
//                   labelText: 'LINE ID',
//                   prefixIcon: const Icon(Icons.chat_bubble_outline),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16))),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: fbController,
//               enabled: _isEditing,
//               decoration: InputDecoration(
//                   labelText: 'ลิงก์ Facebook',
//                   prefixIcon: const Icon(Icons.link),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16))),
//             ),
//             const SizedBox(height: 24),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'ข้อมูลเสริมคัดกรองผู้เลี้ยง',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700),
//               ),
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: currentHomeType,
//               disabledHint: Text(currentHomeType),
//               decoration: InputDecoration(
//                   labelText: 'ประเภทที่พักอาศัย',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16))),
//               items: homeTypes
//                   .map(
//                       (h) => DropdownMenuItem(value: h, child: Text(h)))
//                   .toList(),
//               onChanged: _isEditing
//                   ? (val) => setState(() => currentHomeType = val!)
//                   : null,
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: currentRole,
//               isExpanded: true,
//               disabledHint: Text(
//                 currentRole,
//                 style: const TextStyle(fontSize: 13),
//               ),
//               decoration: InputDecoration(
//                   labelText: 'บทบาทหลักในการเข้าใช้แอป',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16))),
//               items: roles
//                   .map((r) => DropdownMenuItem(
//                       value: r,
//                       child: Text(r,
//                           style: const TextStyle(fontSize: 13))))
//                   .toList(),
//               onChanged:
//                   _isEditing ? (val) => setState(() => currentRole = val!) : null,
//             ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _isEditing ? saveProfileData : startEditing,
//                 icon: Icon(_isEditing ? Icons.save : Icons.edit),
//                 label: Text(_isEditing ? 'บันทึกข้อมูล' : 'แก้ไขข้อมูล',
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFF9E68),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30)),
//                   elevation: 2,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==========================================
// // Part 4.6: Chat Inbox Screen
// // ==========================================
// class ChatInboxScreen extends StatefulWidget {
//   final String dogName;

//   const ChatInboxScreen({super.key, required this.dogName});

//   @override
//   State<ChatInboxScreen> createState() => _ChatInboxScreenState();
// }

// class _ChatInboxScreenState extends State<ChatInboxScreen> {
//   late List<Map<String, dynamic>> inboxChats;

//   @override
//   void initState() {
//     super.initState();
//     // กรองเฉพาะแชทของน้องหมาตัวนี้
//     inboxChats = mockInboxChats
//         .where((chat) => chat['dogName'] == widget.dogName)
//         .toList();
//   }

//   int get totalUnread =>
//       inboxChats.fold(0, (sum, chat) => sum + (chat['unread'] as int));

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFF6F0),
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('กล่องข้อความ',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFFFF9E68),
//                     fontSize: 18)),
//             Text('น้อง${widget.dogName}',
//                 style:
//                     const TextStyle(fontSize: 12, color: Colors.black45)),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Color(0xFFFF9E68)),
//         elevation: 1,
//         actions: [
//           if (totalUnread > 0)
//             Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFF9E68),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '$totalUnread ข้อความใหม่',
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: inboxChats.isEmpty
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.chat_bubble_outline,
//                       size: 64, color: Colors.black12),
//                   SizedBox(height: 16),
//                   Text('ยังไม่มีคนทักมาเลย',
//                       style:
//                           TextStyle(fontSize: 16, color: Colors.grey)),
//                   SizedBox(height: 8),
//                   Text('แชร์โพสต์เพื่อให้คนรู้จักน้องมากขึ้นนะครับ',
//                       style:
//                           TextStyle(fontSize: 13, color: Colors.black38)),
//                 ],
//               ),
//             )
//           : ListView.separated(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               itemCount: inboxChats.length,
//               separatorBuilder: (_, __) =>
//                   const Divider(height: 1, indent: 80),
//               itemBuilder: (context, index) {
//                 final chat = inboxChats[index];
//                 final unread = chat['unread'] as int;

//                 return ListTile(
//                   contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 10),
//                   leading: Stack(
//                     children: [
//                       PetAvatar(
//                         imageUrl: chat['customerAvatar'],
//                         radius: 28,
//                         icon: Icons.person,
//                       ),
//                       if (unread > 0)
//                         Positioned(
//                           right: 0,
//                           top: 0,
//                           child: Container(
//                             width: 18,
//                             height: 18,
//                             decoration: const BoxDecoration(
//                               color: Color(0xFFFF9E68),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Center(
//                               child: Text(
//                                 '$unread',
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   title: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         chat['customerName'],
//                         style: TextStyle(
//                           fontWeight: unread > 0
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                           fontSize: 16,
//                         ),
//                       ),
//                       Text(
//                         chat['time'],
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: unread > 0
//                               ? const Color(0xFFFF9E68)
//                               : Colors.grey,
//                           fontWeight: unread > 0
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   subtitle: Text(
//                     chat['lastMessage'],
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: unread > 0 ? Colors.black87 : Colors.grey,
//                       fontWeight: unread > 0
//                           ? FontWeight.w500
//                           : FontWeight.normal,
//                     ),
//                   ),
//                   onTap: () {
//                     // อ่านแล้ว → reset unread
//                     setState(() {
//                       inboxChats[index]['unread'] = 0;
//                       // อัปเดต global data ด้วย
//                       final globalIndex = mockInboxChats.indexWhere(
//                           (c) => c['chatId'] == chat['chatId']);
//                       if (globalIndex != -1) {
//                         mockInboxChats[globalIndex]['unread'] = 0;
//                       }
//                     });
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ChatScreen(
//                           dogName: chat['dogName'],
//                           isOwnerMode: true,
//                           customerName: chat['customerName'],
//                           customerAvatar: chat['customerAvatar'],
//                           initialMessages: List<Map<String, dynamic>>.from(
//                               chat['messages']),
//                           onNewMessage: (msg) {
//                             // อัปเดต lastMessage เมื่อส่งข้อความใหม่
//                             setState(() {
//                               inboxChats[index]['lastMessage'] = msg;
//                             });
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//     );
//   }
// }

// // ==========================================
// // Part 5: Chat Screen
// // ==========================================
// class ChatScreen extends StatefulWidget {
//   final String dogName;
//   final bool isOwnerMode;
//   final String customerName;
//   final String customerAvatar;
//   final List<Map<String, dynamic>> initialMessages;
//   final Function(String)? onNewMessage;

//   const ChatScreen({
//     super.key,
//     required this.dogName,
//     this.isOwnerMode = false,
//     this.customerName = '',
//     this.customerAvatar = '',
//     this.initialMessages = const [],
//     this.onNewMessage,
//   });

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _msgController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   late List<Map<String, dynamic>> _messages;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialMessages.isNotEmpty) {
//       _messages =
//           List<Map<String, dynamic>>.from(widget.initialMessages);
//     } else if (widget.isOwnerMode) {
//       _messages = [
//         {
//           "text":
//               "สวัสดีครับ สนใจรับเลี้ยงน้อง${widget.dogName} ครับ น้องยังว่างอยู่ไหมครับ?",
//           "isMe": false
//         },
//       ];
//     } else {
//       _messages = [
//         {
//           "text":
//               "สวัสดีครับ สนใจรับเลี้ยงน้องทักสอบถามได้เลยนะครับ/คะ 😊",
//           "isMe": false
//         },
//       ];
//     }
//   }

//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   void _sendMessage() {
//     if (_msgController.text.trim().isEmpty) return;
//     final text = _msgController.text.trim();
//     setState(() {
//       _messages.add({"text": text, "isMe": true});
//     });
//     widget.onNewMessage?.call(text);
//     _msgController.clear();
//     FocusScope.of(context).unfocus();
//     _scrollToBottom();

//     Future.delayed(const Duration(seconds: 1), () {
//       if (mounted) {
//         setState(() {
//           _messages.add({
//             "text": widget.isOwnerMode
//                 ? "ขอบคุณที่สนใจครับ น้อง${widget.dogName}ยังว่างอยู่นะครับ 🐾 สะดวกมาดูน้องวันไหนดีครับ?"
//                 : "ยินดีที่ได้รู้จักครับ สะดวกให้ไปดูน้องได้เลยนะครับ ติดต่อนัดหมายได้เลยครับ",
//             "isMe": false
//           });
//         });
//         _scrollToBottom();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String appBarTitle = widget.isOwnerMode
//         ? (widget.customerName.isNotEmpty
//             ? widget.customerName
//             : 'ผู้สนใจรับเลี้ยง')
//         : 'เจ้าของ${widget.dogName}';

//     return Scaffold(
//       backgroundColor: const Color(0xFFFFF6F0),
//       appBar: AppBar(
//         title: Row(
//           children: [
//             // รูป avatar
//             widget.customerAvatar.isNotEmpty
//                 ? PetAvatar(
//                     imageUrl: widget.customerAvatar,
//                     radius: 20,
//                     icon: Icons.person,
//                     backgroundColor: Colors.white,
//                   )
//                 : const CircleAvatar(
//                     backgroundColor: Colors.white,
//                     radius: 20,
//                     child: Icon(Icons.person,
//                         color: Color(0xFFFF9E68), size: 22),
//                   ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     appBarTitle,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 16),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     'น้อง${widget.dogName}',
//                     style: const TextStyle(
//                         fontSize: 11, color: Colors.white70),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFFFF9E68),
//         foregroundColor: Colors.white,
//         elevation: 1,
//       ),
//       body: Column(
//         children: [
//           // ส่วนแสดงข้อความ
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(16),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final msg = _messages[index];
//                 final isMe = msg['isMe'] as bool;
//                 return Align(
//                   alignment: isMe
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 12),
//                     constraints: BoxConstraints(
//                       maxWidth:
//                           MediaQuery.of(context).size.width * 0.75,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isMe
//                           ? const Color(0xFFFF9E68)
//                           : Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: const Radius.circular(20),
//                         topRight: const Radius.circular(20),
//                         bottomLeft:
//                             Radius.circular(isMe ? 20 : 0),
//                         bottomRight:
//                             Radius.circular(isMe ? 0 : 20),
//                       ),
//                       boxShadow: const [
//                         BoxShadow(
//                             color: Colors.black12, blurRadius: 4)
//                       ],
//                     ),
//                     child: Text(
//                       msg['text'],
//                       style: TextStyle(
//                           color:
//                               isMe ? Colors.white : Colors.black87,
//                           fontSize: 16),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // กล่องพิมพ์ข้อความ
//           Container(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, -2))
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _msgController,
//                     decoration: InputDecoration(
//                       hintText: 'พิมพ์ข้อความ...',
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30),
//                           borderSide: BorderSide.none),
//                       filled: true,
//                       fillColor: Colors.grey.shade100,
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 10),
//                     ),
//                     onSubmitted: (_) => _sendMessage(),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 GestureDetector(
//                   onTap: _sendMessage,
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: const BoxDecoration(
//                         color: Color(0xFFFF9E68),
//                         shape: BoxShape.circle),
//                     child:
//                         const Icon(Icons.send, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
