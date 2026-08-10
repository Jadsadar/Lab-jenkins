import 'package:flutter/material.dart';

import '../../utils/media_utils.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/pet_network_image.dart';
import '../chat/chat_screen.dart';
import '../detail/pet_detail_screen.dart';
import '../reels/reels_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> likedDogs;
  final List<Map<String, dynamic>> savedReels;
  final Function(Map<String, dynamic>) onToggleSaveReel;
  final Function(Map<String, dynamic>) onLikeReel;
  final Set<String> engagedReelIds;
  final List<Map<String, dynamic>> myPostedDogs;
  final Function(Map<String, dynamic>) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.likedDogs,
    required this.savedReels,
    required this.onToggleSaveReel,
    required this.onLikeReel,
    required this.engagedReelIds,
    required this.myPostedDogs,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('รายการที่สนใจ',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Color(0xFFFF9E68),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF9E68),
            tabs: [
              Tab(icon: Icon(Icons.thumb_up), text: "สัตว์เลี้ยงที่ถูกใจ"),
              Tab(icon: Icon(Icons.video_library), text: "รีลที่บันทึก"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            likedDogs.isEmpty
                ? const Center(
                    child: Text('ยังไม่มีสัตว์เลี้ยงที่ถูกใจเลย',
                        style: TextStyle(fontSize: 16, color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: likedDogs.length,
                    itemBuilder: (context, index) {
                      final dog = likedDogs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: PetAvatar(
                            imageUrl: dog['imageUrl'],
                            radius: 30,
                          ),
                          title: Text(dog['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle:
                              Text('${dog['province']} • ${dog['breed']}'),
                          trailing: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        dogName: dog['name'],
                                        isOwnerMode: false))),
                            icon: const Icon(Icons.chat, size: 18),
                            label: const Text('ทักแชท'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB085),
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                          ),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PetDetailScreen(
                                        dog: dog,
                                        isMyPost: false,
                                        isFavorited: likedDogs
                                            .any((d) => d['id'] == dog['id']),
                                        onToggleFavorite: () =>
                                            onToggleFavorite(dog),
                                      ))),
                        ),
                      );
                    },
                  ),
            savedReels.isEmpty
                ? const Center(
                    child: Text('ยังไม่ได้บันทึกวิดีโอใดๆ',
                        style: TextStyle(fontSize: 16, color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: savedReels.length,
                    itemBuilder: (context, index) {
                      final dog = savedReels[index];
                      final isReelLiked = engagedReelIds.contains(dog['id']);
                      final isSaved =
                          savedReels.any((d) => d['id'] == dog['id']);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReelsScreen(
                                            activeReels: savedReels,
                                            engagedReelIds: engagedReelIds,
                                            savedReels: savedReels,
                                            onLikeReel: onLikeReel,
                                            onToggleSave: onToggleSaveReel,
                                            myPostedDogs: myPostedDogs,
                                            onGoToUpload: () {},
                                            initialIndex: index,
                                            likedDogs: likedDogs,
                                            onToggleFavorite: onToggleFavorite,
                                          ))),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // วิดีโอใช้รูปโปรไฟล์เป็นภาพปก
                                      // (ยังไม่ได้ทำ thumbnail จากคลิปจริง)
                                      PetNetworkImage(
                                        imageUrl: isVideoSource(dog['reelUrl'])
                                            ? dog['imageUrl']
                                            : dog['reelUrl'] ?? dog['imageUrl'],
                                        fit: BoxFit.cover,
                                      ),
                                      // ไอคอนเล่นขึ้นเฉพาะรีลที่เป็นวิดีโอจริง
                                      if (isVideoSource(dog['reelUrl']))
                                        const Center(
                                            child: Icon(
                                                Icons.play_circle_outline,
                                                color: Colors.white70,
                                                size: 50)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: PetAvatar(imageUrl: dog['imageUrl']),
                              title: Text('วิดีโอของ ${dog['name']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: const Text(
                                  'กดเพื่อดูโปรไฟล์ และเตรียมรับเลี้ยง',
                                  style: TextStyle(fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => onLikeReel(dog),
                                    icon: Icon(
                                        isReelLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.redAccent,
                                        size: 28),
                                  ),
                                  IconButton(
                                    onPressed: () => onToggleSaveReel(dog),
                                    icon: Icon(
                                        isSaved
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: const Color(0xFFFF9E68),
                                        size: 28),
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PetDetailScreen(
                                            dog: dog,
                                            isMyPost: myPostedDogs.any(
                                                (myDog) =>
                                                    myDog['id'] ==
                                                    dog['id']),
                                            isFavorited: likedDogs.any(
                                                (d) => d['id'] == dog['id']),
                                            onToggleFavorite: () =>
                                                onToggleFavorite(dog),
                                          ))),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
