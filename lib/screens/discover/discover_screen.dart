import 'package:flutter/material.dart';

import '../../widgets/swipeable_card.dart';

class DiscoverScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dogs;
  final Function(Map<String, dynamic>) onLike;
  final Function(Map<String, dynamic>) onPass;
  final VoidCallback onUndoPass;
  final bool canUndo;
  final List<Map<String, dynamic>> likedDogs;
  final Function(Map<String, dynamic>) onToggleFavorite;

  const DiscoverScreen({
    super.key,
    required this.dogs,
    required this.onLike,
    required this.onPass,
    required this.onUndoPass,
    required this.canUndo,
    required this.likedDogs,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetPaws',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: dogs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ขอบคุณที่ทำให้สัตว์ทุกตัวมีบ้านที่อบอุ่น!',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  if (canUndo) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: onUndoPass,
                      icon: const Icon(Icons.replay),
                      label: const Text('ลองดูสัตว์เลี้ยงอีกครั้ง'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB085),
                          foregroundColor: Colors.white),
                    )
                  ]
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SwipeableCard(
                      dog: dogs.first,
                      onLike: () => onLike(dogs.first),
                      onPass: () => onPass(dogs.first),
                      likedDogs: likedDogs,
                      onToggleFavorite: onToggleFavorite,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: "btn_pass",
                        onPressed: () => onPass(dogs.first),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.redAccent.shade200,
                        elevation: 2,
                        child: const Icon(Icons.close, size: 30),
                      ),
                      const SizedBox(width: 24),
                      FloatingActionButton(
                        heroTag: "btn_undo",
                        onPressed: canUndo ? onUndoPass : null,
                        backgroundColor:
                            canUndo ? Colors.white : Colors.grey[200],
                        foregroundColor: const Color(0xFFFFB085),
                        mini: true,
                        elevation: canUndo ? 2 : 0,
                        child: const Icon(Icons.replay, size: 24),
                      ),
                      const SizedBox(width: 24),
                      FloatingActionButton(
                        heroTag: "btn_like",
                        onPressed: () => onLike(dogs.first),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green.shade400,
                        elevation: 2,
                        child: const Icon(Icons.favorite, size: 30),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
