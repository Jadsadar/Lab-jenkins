import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/mock_dogs.dart';
import '../utils/media_utils.dart';
import 'discover/discover_screen.dart';
import 'favorites/favorites_screen.dart';
import 'profile/profile_screen.dart';
import 'reels/reels_screen.dart';
import 'upload/upload_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> allDogs =
      List<Map<String, dynamic>>.from(initialDogs);
  List<Map<String, dynamic>> myPostedDogs =
      List<Map<String, dynamic>>.from(initialMyPostedDogs);

  List<Map<String, dynamic>> likedDogs = [];
  List<Map<String, dynamic>> passedDogs = [];
  List<Map<String, dynamic>> savedReels = [];
  Set<String> engagedReelIds =
      {}; // เก็บ ID ของรีลที่ผู้ใช้เคยกด Like เพื่อเป็นยอดเอนเกจเมนต์

  void onLike(Map<String, dynamic> dog) => setState(() {
        likedDogs.add(dog);
        allDogs.remove(dog);
      });

  void onPass(Map<String, dynamic> dog) => setState(() {
        passedDogs.add(dog);
        allDogs.remove(dog);
      });

  void onUndoPass() {
    if (passedDogs.isNotEmpty) {
      setState(() {
        allDogs.insert(0, passedDogs.removeLast());
      });
    }
  }

  void onAddDog(Map<String, dynamic> newDog) =>
      setState(() => myPostedDogs.insert(0, newDog));

  void onDeleteDog(Map<String, dynamic> dog) => setState(() {
        myPostedDogs.remove(dog);
        savedReels.removeWhere((d) => d['id'] == dog['id']);
      });

  void onEditDog(Map<String, dynamic> updatedDog) => setState(() {
        final index =
            myPostedDogs.indexWhere((d) => d['id'] == updatedDog['id']);
        if (index != -1) myPostedDogs[index] = updatedDog;
      });

  void onChangeStatus(Map<String, dynamic> dog, String newStatus) =>
      setState(() {
        final index = myPostedDogs.indexWhere((d) => d['id'] == dog['id']);
        if (index != -1) myPostedDogs[index]['status'] = newStatus;
      });

  // ฟังก์ชันสำหรับการกดถูกใจรีล (Engagement)
  void onLikeReel(Map<String, dynamic> dog) => setState(() {
        final dogId = dog['id'];
        if (engagedReelIds.contains(dogId)) {
          engagedReelIds.remove(dogId);
          dog['engagementLikes'] = (dog['engagementLikes'] ?? 1) - 1;
        } else {
          engagedReelIds.add(dogId);
          dog['engagementLikes'] = (dog['engagementLikes'] ?? 0) + 1;
        }
      });

  // ฟังก์ชันสำหรับการกดสนใจรับเลี้ยง
  void onToggleFavoriteDog(Map<String, dynamic> dog) => setState(() {
        final exists = likedDogs.any((d) => d['id'] == dog['id']);
        if (exists) {
          likedDogs.removeWhere((d) => d['id'] == dog['id']);
        } else {
          likedDogs.add(dog);
          allDogs.removeWhere((d) => d['id'] == dog['id']);
        }
      });

  void onToggleSaveReel(Map<String, dynamic> dog) => setState(() {
        if (savedReels.any((d) => d['id'] == dog['id'])) {
          savedReels.removeWhere((d) => d['id'] == dog['id']);
        } else {
          savedReels.add(dog);
        }
      });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> activeReels =
        [...allDogs, ...myPostedDogs].where((dog) {
      final isAvailable =
          (dog['status'] ?? 'ยังไม่ถูกรับเลี้ยง') == 'ยังไม่ถูกรับเลี้ยง';
      return isAvailable && hasReelMedia(dog);
    }).toList();

    final List<Widget> screens = [
      DiscoverScreen(
        dogs: allDogs,
        onLike: onLike,
        onPass: onPass,
        onUndoPass: onUndoPass,
        canUndo: passedDogs.isNotEmpty,
        likedDogs: likedDogs,
        onToggleFavorite: onToggleFavoriteDog,
      ),
      ReelsScreen(
        activeReels: activeReels,
        engagedReelIds: engagedReelIds,
        savedReels: savedReels,
        onLikeReel: onLikeReel,
        onToggleSave: onToggleSaveReel,
        myPostedDogs: myPostedDogs,
        onGoToUpload: () => setState(() => _selectedIndex = 3),
        likedDogs: likedDogs,
        onToggleFavorite: onToggleFavoriteDog,
      ),
      FavoritesScreen(
        likedDogs: likedDogs,
        savedReels: savedReels,
        onToggleSaveReel: onToggleSaveReel,
        engagedReelIds: engagedReelIds,
        onLikeReel: onLikeReel,
        myPostedDogs: myPostedDogs,
        onToggleFavorite: onToggleFavoriteDog,
      ),
      UploadScreen(
        onAddDog: onAddDog,
        myPostedDogs: myPostedDogs,
        onDeleteDog: onDeleteDog,
        onEditDog: onEditDog,
        onChangeStatus: onChangeStatus,
        likedDogs: likedDogs,
        onToggleFavorite: onToggleFavoriteDog,
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF9E68),
        unselectedItemColor: Colors.grey.shade400,
        backgroundColor: Colors.white,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'ค้นหา'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.video_library), label: 'รีล'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'ถูกใจ'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.post_add), label: 'ลงประกาศ'),
          // ไอคอนโปรไฟล์ + badge แจ้งเตือน unread
          BottomNavigationBarItem(
            label: 'โปรไฟล์',
            icon: ValueListenableBuilder<int>(
              valueListenable: unreadCounter,
              builder: (context, unread, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.person),
                    if (unread > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
