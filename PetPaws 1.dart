  // import 'package:flutter/material.dart';
  // import 'dart:convert';
  // import 'package:http/http.dart' as http;

  // void main() {
  //   runApp(const PawsMatchApp());
  // }

  // class PawsMatchApp extends StatelessWidget {
  //   const PawsMatchApp({super.key});

  //   @override
  //   Widget build(BuildContext context) {
  //     return MaterialApp(
  //       debugShowCheckedModeBanner: false,
  //       title: 'PawsMatch',
  //       theme: ThemeData(
  //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
  //         useMaterial3: true,
  //         fontFamily: 'Roboto',
  //       ),
  //       home: const MainScreen(),
  //     );
  //   }
  // }

  // // ==========================================
  // // Main Screen (Contains Bottom Navigation)
  // // ==========================================
  // class MainScreen extends StatefulWidget {
  //   const MainScreen({super.key});

  //   @override
  //   State<MainScreen> createState() => _MainScreenState();
  // }

  // class _MainScreenState extends State<MainScreen> {
  //   int _selectedIndex = 0;
  //   List<dynamic> allDogs = [];
  //   List<dynamic> likedDogs = []; // เก็บสุนัขที่ถูกใจ
  //   bool isLoading = true;

  //   @override
  //   void initState() {
  //     super.initState();
  //     fetchDogs();
  //   }

  //   // ดึงข้อมูลสุนัขทั้งหมดจาก API (อัปเดตระบบป้องกัน Error และเพิ่มข้อมูลสำรอง)
  //   Future<void> fetchDogs() async {
  //     try {
  //       final url = Uri.parse('https://api.thedogapi.com/v1/breeds');
  //       final response = await http.get(url);

  //       if (response.statusCode == 200) {
  //         final data = jsonDecode(response.body) as List;
  //         // กรองเอาเฉพาะข้อมูลที่มีรูปภาพมาให้ (รองรับทั้ง image.url และ reference_image_id)
  //         allDogs = data.where((dog) => dog['image'] != null || dog['reference_image_id'] != null).toList();
          
  //         // จัดเตรียม URL รูปภาพให้พร้อมใช้งาน
  //         for (var dog in allDogs) {
  //           if (dog['image'] != null && dog['image']['url'] != null) {
  //             dog['imageUrl'] = dog['image']['url'];
  //           } else if (dog['reference_image_id'] != null) {
  //             dog['imageUrl'] = 'https://cdn2.thedogapi.com/images/${dog["reference_image_id"]}.jpg';
  //           } else {
  //             dog['imageUrl'] = 'https://images.unsplash.com/photo-1543852786-1cf6624b9987?auto=format&fit=crop&w=400&q=60';
  //           }
  //         }

  //         // สลับข้อมูลแบบสุ่ม (Shuffle) เพื่อให้สนุกขึ้นเหมือนทินเดอร์
  //         allDogs.shuffle();
  //       } else {
  //         debugPrint('API Error: Status Code ${response.statusCode}');
  //       }
  //     } catch (e) {
  //       debugPrint('Error fetching dogs: $e');
  //     } finally {
  //       // Fallback Data: ถ้า API พังหรือโหลดไม่ติด ให้ใช้ข้อมูลจำลองนี้แสดงผลแทน เพื่อป้องกันแอปพังตอนพรีเซนต์
  //       if (allDogs.isEmpty) {
  //         allDogs = [
  //           {
  //             "id": "mock1",
  //             "name": "Golden Retriever",
  //             "breed_group": "Sporting",
  //             "bred_for": "Retrieving water fowl",
  //             "life_span": "10 - 12 years",
  //             "temperament": "Intelligent, Kind, Reliable, Friendly",
  //             "weight": {"metric": "25 - 32"},
  //             "height": {"metric": "51 - 61"},
  //             "imageUrl": "https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=500&q=60"
  //           },
  //           {
  //             "id": "mock2",
  //             "name": "Siberian Husky",
  //             "breed_group": "Working",
  //             "bred_for": "Sled pulling",
  //             "life_span": "12 - 15 years",
  //             "temperament": "Outgoing, Friendly, Alert, Gentle",
  //             "weight": {"metric": "16 - 27"},
  //             "height": {"metric": "51 - 60"},
  //             "imageUrl": "https://images.unsplash.com/photo-1605568427561-40dd23c2acea?auto=format&fit=crop&w=500&q=60"
  //           },
  //           {
  //             "id": "mock3",
  //             "name": "Welsh Corgi (Pembroke)",
  //             "breed_group": "Herding",
  //             "bred_for": "Driving stock to market",
  //             "life_span": "12 - 14 years",
  //             "temperament": "Tenacious, Outgoing, Friendly, Bold",
  //             "weight": {"metric": "11 - 14"},
  //             "height": {"metric": "25 - 30"},
  //             "imageUrl": "https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=500&q=60"
  //           },
  //           {
  //             "id": "mock4",
  //             "name": "Pug",
  //             "breed_group": "Toy",
  //             "bred_for": "Lapdog",
  //             "life_span": "12 - 14 years",
  //             "temperament": "Docile, Clever, Charming, Stubborn, Sociable",
  //             "weight": {"metric": "6 - 8"},
  //             "height": {"metric": "25 - 30"},
  //             "imageUrl": "https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=500&q=60"
  //           }
  //         ];
  //       }

  //       // การันตีว่าหลอดโหลดจะถูกสั่งให้หยุดหมุนแน่นอน
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }

  //   // ฟังก์ชันสำหรับเวลากด Like
  //   void onLike(dynamic dog) {
  //     setState(() {
  //       likedDogs.add(dog);
  //       allDogs.remove(dog); // เอาน้องออกจากกองการ์ด
  //     });
  //   }

  //   // ฟังก์ชันสำหรับเวลากด Pass (ไม่ชอบ)
  //   void onPass(dynamic dog) {
  //     setState(() {
  //       allDogs.remove(dog); // เอาน้องออกจากกองการ์ดเฉยๆ
  //     });
  //   }

  //   @override
  //   Widget build(BuildContext context) {
  //     // กำหนดหน้าจอที่จะสลับไปมาตาม Bottom Nav
  //     final List<Widget> screens = [
  //       DiscoverScreen(
  //         isLoading: isLoading,
  //         dogs: allDogs,
  //         onLike: onLike,
  //         onPass: onPass,
  //       ),
  //       FavoritesScreen(likedDogs: likedDogs),
  //     ];

  //     return Scaffold(
  //       body: screens[_selectedIndex],
  //       bottomNavigationBar: BottomNavigationBar(
  //         currentIndex: _selectedIndex,
  //         onTap: (index) {
  //           setState(() {
  //             _selectedIndex = index;
  //           });
  //         },
  //         selectedItemColor: Colors.pinkAccent,
  //         unselectedItemColor: Colors.grey,
  //         items: const [
  //           BottomNavigationBarItem(
  //             icon: Icon(Icons.pets),
  //             label: 'Discover',
  //           ),
  //           BottomNavigationBarItem(
  //             icon: Icon(Icons.favorite),
  //             label: 'Matches',
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  // // ==========================================
  // // Part 1: Discover Screen (Tinder Swipe Logic)
  // // ==========================================
  // class DiscoverScreen extends StatelessWidget {
  //   final bool isLoading;
  //   final List<dynamic> dogs;
  //   final Function(dynamic) onLike;
  //   final Function(dynamic) onPass;

  //   const DiscoverScreen({
  //     super.key,
  //     required this.isLoading,
  //     required this.dogs,
  //     required this.onLike,
  //     required this.onPass,
  //   });

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       backgroundColor: Colors.grey[100],
  //       appBar: AppBar(
  //         title: const Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(Icons.pets, color: Colors.pinkAccent),
  //             SizedBox(width: 8),
  //             Text('PawsMatch', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
  //           ],
  //         ),
  //         backgroundColor: Colors.white,
  //         elevation: 1,
  //         centerTitle: true,
  //       ),
  //       body: isLoading
  //           ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
  //           : dogs.isEmpty
  //               ? const Center(
  //                   child: Text('No more dogs around you!', style: TextStyle(fontSize: 18, color: Colors.grey)),
  //                 )
  //               // แสดงการ์ดใบแรกสุด (dogs.first) ให้เราปัด
  //               : Center(
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(16.0),
  //                     child: SwipeableCard(
  //                       dog: dogs.first,
  //                       onLike: () => onLike(dogs.first),
  //                       onPass: () => onPass(dogs.first),
  //                     ),
  //                   ),
  //                 ),
  //     );
  //   }
  // }

  // // Widget สำหรับการ์ดที่สามารถลากปัดซ้าย-ขวาได้
  // class SwipeableCard extends StatelessWidget {
  //   final dynamic dog;
  //   final VoidCallback onLike;
  //   final VoidCallback onPass;

  //   const SwipeableCard({
  //     super.key,
  //     required this.dog,
  //     required this.onLike,
  //     required this.onPass,
  //   });

  //   @override
  //   Widget build(BuildContext context) {
  //     // ใช้ Dismissible ในการสร้าง Effect ปัดซ้าย/ขวา
  //     return Dismissible(
  //       key: Key(dog['id'].toString()), // ต้องมี key ไม่ซ้ำกัน
  //       onDismissed: (direction) {
  //         if (direction == DismissDirection.endToStart) {
  //           onPass(); // ปัดซ้าย (End to Start) = Pass
  //         } else if (direction == DismissDirection.startToEnd) {
  //           onLike(); // ปัดขวา (Start to End) = Like
  //         }
  //       },
  //       // พื้นหลังสีเขียวตอนปัดขวา (Like)
  //       background: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.green,
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         alignment: Alignment.centerLeft,
  //         padding: const EdgeInsets.symmetric(horizontal: 40),
  //         child: const Icon(Icons.favorite, color: Colors.white, size: 50),
  //       ),
  //       // พื้นหลังสีแดงตอนปัดซ้าย (Pass)
  //       secondaryBackground: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.redAccent,
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         alignment: Alignment.centerRight,
  //         padding: const EdgeInsets.symmetric(horizontal: 40),
  //         child: const Icon(Icons.close, color: Colors.white, size: 50),
  //       ),
  //       child: GestureDetector(
  //         onTap: () {
  //           // กดที่การ์ดเพื่อดูรายละเอียดเพิ่มเติม
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => PetDetailScreen(dog: dog)),
  //           );
  //         },
  //         child: Container(
  //           width: double.infinity,
  //           height: MediaQuery.of(context).size.height * 0.65, // สูง 65% ของหน้าจอ
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(20),
  //             color: Colors.white,
  //             boxShadow: const [
  //               BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
  //             ],
  //           ),
  //           child: Stack(
  //             fit: StackFit.expand,
  //             children: [
  //               // ส่วนของรูปภาพ พร้อมดักจับ Error กรณีโหลดรูปไม่ขึ้น
  //               ClipRRect(
  //                 borderRadius: BorderRadius.circular(20),
  //                 child: Image.network(
  //                   dog['imageUrl'] ?? '',
  //                   fit: BoxFit.cover,
  //                   errorBuilder: (context, error, stackTrace) {
  //                     return Container(
  //                       color: Colors.grey[200],
  //                       child: const Icon(Icons.pets, size: 80, color: Colors.grey),
  //                     );
  //                   },
  //                 ),
  //               ),
  //               // ส่วนของเงาดำด้านล่างและข้อความ
  //               Container(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(20),
  //                   // ใส่ Gradient สีดำด้านล่างเพื่อให้ตัวหนังสือชัดขึ้น
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
  //                     Text(
  //                       dog['name'],
  //                       style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Text(
  //                       dog['breed_group'] ?? 'Unknown Group',
  //                       style: const TextStyle(color: Colors.white70, fontSize: 18),
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
  // // Part 2: Favorites Screen (Matches)
  // // ==========================================
  // class FavoritesScreen extends StatelessWidget {
  //   final List<dynamic> likedDogs;

  //   const FavoritesScreen({super.key, required this.likedDogs});

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: AppBar(
  //         title: const Text('My Matches', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
  //         backgroundColor: Colors.white,
  //         elevation: 1,
  //         centerTitle: true,
  //       ),
  //       body: likedDogs.isEmpty
  //           ? const Center(
  //               child: Text(
  //                 'No matches yet. Go swipe some paws!',
  //                 style: TextStyle(fontSize: 16, color: Colors.grey),
  //               ),
  //             )
  //           : GridView.builder(
  //               padding: const EdgeInsets.all(12),
  //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //                 crossAxisCount: 2, // 2 คอลัมน์
  //                 crossAxisSpacing: 10,
  //                 mainAxisSpacing: 10,
  //                 childAspectRatio: 0.8, // สัดส่วนความกว้าง:ความสูง
  //               ),
  //               itemCount: likedDogs.length,
  //               itemBuilder: (context, index) {
  //                 final dog = likedDogs[index];
  //                 return GestureDetector(
  //                   onTap: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(builder: (context) => PetDetailScreen(dog: dog)),
  //                     );
  //                   },
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(16),
  //                     child: Stack(
  //                       fit: StackFit.expand,
  //                       children: [
  //                         Image.network(
  //                           dog['imageUrl'] ?? '',
  //                           fit: BoxFit.cover,
  //                           errorBuilder: (context, error, stackTrace) {
  //                             return Container(
  //                               color: Colors.grey[200],
  //                               child: const Icon(Icons.pets, size: 40, color: Colors.grey),
  //                             );
  //                           },
  //                         ),
  //                         Container(
  //                           decoration: const BoxDecoration(
  //                             gradient: LinearGradient(
  //                               colors: [Colors.transparent, Colors.black87],
  //                               begin: Alignment.topCenter,
  //                               end: Alignment.bottomCenter,
  //                               stops: [0.5, 1.0],
  //                             ),
  //                           ),
  //                         ),
  //                         Positioned(
  //                           bottom: 12,
  //                           left: 12,
  //                           right: 12,
  //                           child: Text(
  //                             dog['name'],
  //                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                         )
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //     );
  //   }
  // }

  // // ==========================================
  // // Part 3: Pet Detail Screen
  // // ==========================================
  // class PetDetailScreen extends StatelessWidget {
  //   final dynamic dog;

  //   const PetDetailScreen({super.key, required this.dog});

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       extendBodyBehindAppBar: true, // ให้รูปภาพทะลุ AppBar ขึ้นไปด้านบนสุด
  //       appBar: AppBar(
  //         backgroundColor: Colors.transparent,
  //         elevation: 0,
  //         iconTheme: const IconThemeData(color: Colors.white), // ปุ่ม Back สีขาว
  //       ),
  //       body: SingleChildScrollView(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Hero Image
  //             Image.network(
  //               dog['imageUrl'] ?? '',
  //               width: double.infinity,
  //               height: 400,
  //               fit: BoxFit.cover,
  //               errorBuilder: (context, error, stackTrace) {
  //                 return Container(
  //                   width: double.infinity,
  //                   height: 400,
  //                   color: Colors.grey[200],
  //                   child: const Icon(Icons.pets, size: 80, color: Colors.grey),
  //                 );
  //               },
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(24.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     dog['name'],
  //                     style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Text(
  //                     'Bred for: ${dog['bred_for'] ?? 'Companionship'}',
  //                     style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: FontStyle.italic),
  //                   ),
  //                   const SizedBox(height: 24),
                    
  //                   // Info Cards
  //                   Row(
  //                     children: [
  //                       _buildInfoCard(Icons.monitor_weight, 'Weight', '${dog['weight']['metric'] ?? '?'} kg'),
  //                       const SizedBox(width: 16),
  //                       _buildInfoCard(Icons.height, 'Height', '${dog['height']['metric'] ?? '?'} cm'),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 16),
  //                   Row(
  //                     children: [
  //                       _buildInfoCard(Icons.favorite, 'Life Span', dog['life_span'] ?? '?'),
  //                     ],
  //                   ),
                    
  //                   const SizedBox(height: 32),
  //                   const Text(
  //                     'Temperament',
  //                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  //                   ),
  //                   const SizedBox(height: 12),
  //                   // แสดง Tag นิสัย
  //                   Wrap(
  //                     spacing: 8.0,
  //                     runSpacing: 8.0,
  //                     children: (dog['temperament'] != null)
  //                         ? (dog['temperament'] as String).split(',').map((temp) {
  //                             return Chip(
  //                               label: Text(temp.trim(), style: const TextStyle(color: Colors.pinkAccent)),
  //                               backgroundColor: Colors.pink.shade50,
  //                               side: BorderSide.none,
  //                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //                             );
  //                           }).toList()
  //                         : [const Text('No temperament data available.')],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  //   // Widget ช่วยวาดกล่องข้อมูลเล็กๆ
  //   Widget _buildInfoCard(IconData icon, String title, String value) {
  //     return Expanded(
  //       child: Container(
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.grey[100],
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Icon(icon, color: Colors.pinkAccent),
  //             const SizedBox(height: 12),
  //             Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
  //             const SizedBox(height: 4),
  //             Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  // }