import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../utils/media_utils.dart';
import 'pet_network_image.dart';

/// แสดงสื่อของรีล 1 ชิ้น
/// - ถ้าเป็นไฟล์วิดีโอ จะเล่นจริงด้วย video_player (แตะเพื่อเล่น/หยุด)
/// - ถ้าเป็นภาพนิ่ง จะแสดงรูปเฉยๆ ไม่มีปุ่มเล่นหลอก
class ReelPlayer extends StatefulWidget {
  /// ที่อยู่สื่อของรีล เช่น 'assets/videos/dog1.mp4' หรือ URL รูปภาพ
  final String? source;

  /// รูปโปรไฟล์ของน้อง ใช้เป็นภาพสำรองเมื่อวิดีโอโหลดไม่ได้
  final String? fallbackImageUrl;

  /// หน้านี้กำลังแสดงอยู่หรือไม่ (ใช้สั่งเล่น/หยุดอัตโนมัติ)
  final bool isActive;

  /// สิ่งที่จะทำเมื่อแตะภาพนิ่ง (วิดีโอจะใช้การแตะเพื่อเล่น/หยุดแทน)
  final VoidCallback? onTapImage;

  const ReelPlayer({
    super.key,
    required this.source,
    required this.isActive,
    this.fallbackImageUrl,
    this.onTapImage,
  });

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _hasError = false;
  bool _isPlaying = false;

  bool get _isVideo => isVideoSource(widget.source);

  @override
  void initState() {
    super.initState();
    if (_isVideo) _initVideo();
  }

  @override
  void didUpdateWidget(covariant ReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // เปลี่ยนไฟล์สื่อ ต้องสร้าง controller ใหม่
    if (oldWidget.source != widget.source) {
      _disposeVideo();
      setState(() {
        _isReady = false;
        _hasError = false;
      });
      if (_isVideo) _initVideo();
      return;
    }

    if (oldWidget.isActive != widget.isActive) _syncPlayback();
  }

  Future<void> _initVideo() async {
    final source = widget.source!.trim();
    final controller = isAssetSource(source)
        ? VideoPlayerController.asset(source)
        : VideoPlayerController.networkUrl(Uri.parse(source));
    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      await controller.setLooping(true);
      controller.addListener(_onPlaybackChanged);
      setState(() => _isReady = true);
      _syncPlayback();
    } catch (_) {
      // โหลดวิดีโอไม่สำเร็จ (ไฟล์หาย/ฟอร์แมตไม่รองรับ) ให้ตกไปใช้ภาพนิ่งแทน
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  /// อัปเดตหน้าจอเฉพาะตอนสถานะเล่น/หยุดเปลี่ยนจริงๆ (ไม่ rebuild ทุกเฟรม)
  void _onPlaybackChanged() {
    final playing = _controller?.value.isPlaying ?? false;
    if (playing == _isPlaying || !mounted) return;
    setState(() => _isPlaying = playing);
  }

  void _syncPlayback() {
    final controller = _controller;
    if (controller == null || !_isReady) return;
    if (widget.isActive) {
      controller.play();
    } else {
      controller.pause();
      controller.seekTo(Duration.zero);
    }
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null || !_isReady) return;
    controller.value.isPlaying ? controller.pause() : controller.play();
  }

  void _disposeVideo() {
    _controller?.removeListener(_onPlaybackChanged);
    _controller?.dispose();
    _controller = null;
    _isPlaying = false;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  Widget _buildImage() => PetNetworkImage(
        imageUrl: widget.source ?? widget.fallbackImageUrl,
        fit: BoxFit.cover,
        backgroundColor: Colors.black,
        iconColor: Colors.white24,
        iconSize: 96,
      );

  @override
  Widget build(BuildContext context) {
    // ภาพนิ่ง: แตะแล้วไปหน้าโปรไฟล์ ไม่มีไอคอนเล่นวิดีโอ
    if (!_isVideo) {
      return GestureDetector(onTap: widget.onTapImage, child: _buildImage());
    }

    // วิดีโอเสีย: ใช้รูปโปรไฟล์ของน้องแทน
    if (_hasError) {
      return GestureDetector(
        onTap: widget.onTapImage,
        child: PetNetworkImage(
          imageUrl: widget.fallbackImageUrl,
          fit: BoxFit.cover,
          backgroundColor: Colors.black,
          iconColor: Colors.white24,
          iconSize: 96,
        ),
      );
    }

    final controller = _controller;
    if (!_isReady || controller == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white24),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.black,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),

          // ไอคอนเล่นจะโผล่เฉพาะตอนหยุดวิดีโอไว้เท่านั้น
          AnimatedOpacity(
            opacity: _isPlaying ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: const Center(
              child: Icon(Icons.play_arrow_rounded,
                  color: Colors.white70, size: 100),
            ),
          ),

          // แถบความคืบหน้าบางๆ ด้านล่างสุด
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Color(0xFFFF9E68),
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
