import 'package:flutter/material.dart';

import '../../widgets/pet_avatar.dart';
import '../../widgets/reel_player.dart';
import '../detail/pet_detail_screen.dart';

class ReelsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> activeReels;
  final Set<String> engagedReelIds;
  final List<Map<String, dynamic>> savedReels;
  final Function(Map<String, dynamic>) onLikeReel;
  final Function(Map<String, dynamic>) onToggleSave;
  final List<Map<String, dynamic>> myPostedDogs;
  final int initialIndex;
  final VoidCallback onGoToUpload;
  final List<Map<String, dynamic>> likedDogs;
  final Function(Map<String, dynamic>) onToggleFavorite;

  const ReelsScreen({
    super.key,
    required this.activeReels,
    required this.engagedReelIds,
    required this.savedReels,
    required this.onLikeReel,
    required this.onToggleSave,
    required this.myPostedDogs,
    required this.onGoToUpload,
    required this.likedDogs,
    required this.onToggleFavorite,
    this.initialIndex = 0,
  });

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late PageController _pageController;

  /// รีลที่กำลังแสดงอยู่ ใช้สั่งให้เล่นเฉพาะคลิปนี้คลิปเดียว
  late int _currentPage;

  /// true เมื่อเปิดหน้าอื่นทับอยู่ เพื่อหยุดวิดีโอไม่ให้เล่นค้างหลังฉาก
  bool _isCoveredByOtherScreen = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// เปิดหน้าโปรไฟล์ของน้อง โดยหยุดวิดีโอระหว่างที่ออกไปดูหน้าอื่น
  Future<void> _openDetail(Map<String, dynamic> dog, bool isMyPost) async {
    setState(() => _isCoveredByOtherScreen = true);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailScreen(
          dog: dog,
          isMyPost: isMyPost,
          fromReels: true,
          isFavorited: widget.likedDogs.any((d) => d['id'] == dog['id']),
          onToggleFavorite: () => widget.onToggleFavorite(dog),
        ),
      ),
    );
    if (mounted) setState(() => _isCoveredByOtherScreen = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activeReels.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: Navigator.canPop(context)
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white))
            : null,
        body: const Center(
            child: Text('ไม่มีวิดีโอในขณะนี้',
                style: TextStyle(color: Colors.white, fontSize: 18))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.activeReels.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final dog = widget.activeReels[index];
              final isReelLiked = widget.engagedReelIds.contains(dog['id']);
              final isSaved =
                  widget.savedReels.any((d) => d['id'] == dog['id']);
              final isMyPost =
                  widget.myPostedDogs.any((myDog) => myDog['id'] == dog['id']);

              return Stack(
                fit: StackFit.expand,
                children: [
                  ReelPlayer(
                    source: dog['reelUrl'] ?? dog['imageUrl'],
                    fallbackImageUrl: dog['imageUrl'],
                    isActive: index == _currentPage && !_isCoveredByOtherScreen,
                    onTapImage: () => _openDetail(dog, isMyPost),
                  ),
                  // ไล่เฉดดำด้านล่างให้อ่านตัวหนังสือออก
                  // ครอบ IgnorePointer ไว้ เพื่อให้แตะทะลุไปสั่งเล่น/หยุดวิดีโอได้
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black87],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.6, 1.0],
                        ),
                      ),
                      child: SizedBox.expand(),
                    ),
                  ),

                  // ข้อมูลซ้ายล่าง
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 80,
                    child: GestureDetector(
                      onTap: () => _openDetail(dog, isMyPost),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                PetAvatar(
                                  imageUrl: dog['imageUrl'],
                                  radius: 20,
                                  backgroundColor: Colors.white24,
                                  iconColor: Colors.white70,
                                ),
                                const SizedBox(width: 12),
                                Text(dog['name'],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                                'พิกัด: ${dog['province']} • สายพันธุ์: ${dog['breed']}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(dog['story'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ปุ่มขวาล่าง
                  Positioned(
                    bottom: 20,
                    right: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionItem(
                          icon: Icons.person,
                          label: 'Profile',
                          color: Colors.white,
                          onTap: () => _openDetail(dog, isMyPost),
                        ),
                        if (!isMyPost) ...[
                          _buildActionItem(
                            icon: isReelLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            label: 'Like',
                            color:
                                isReelLiked ? Colors.redAccent : Colors.white,
                            onTap: () {
                              widget.onLikeReel(dog);
                              setState(() {});
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isReelLiked
                                      ? 'เลิกถูกใจวิดีโอแล้ว'
                                      : 'ถูกใจวิดีโอนี้แล้ว'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          _buildActionItem(
                            icon: isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            label: 'Save',
                            color: isSaved
                                ? const Color(0xFFFF9E68)
                                : Colors.white,
                            onTap: () {
                              widget.onToggleSave(dog);
                              setState(() {});
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isSaved
                                      ? 'เลิกบันทึกวิดีโอแล้ว'
                                      : 'บันทึกวิดีโอแล้ว'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          if (Navigator.canPop(context))
            Positioned(
              top: 40,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          if (!Navigator.canPop(context))
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: widget.onGoToUpload,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white70, width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Text('เพิ่มรีล',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
