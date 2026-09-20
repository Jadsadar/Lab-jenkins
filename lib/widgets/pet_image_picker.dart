import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'pet_network_image.dart';

/// กล่องแตะเพื่อเลือกรูปสัตว์เลี้ยงจากเครื่อง พร้อมพรีวิวรูปที่เลือก/รูปเดิม
class PetImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final ValueChanged<Uint8List?> onChanged;

  const PetImagePicker({
    super.key,
    this.initialImageUrl,
    required this.onChanged,
  });

  @override
  State<PetImagePicker> createState() => _PetImagePickerState();
}

class _PetImagePickerState extends State<PetImagePicker> {
  Uint8List? _pickedBytes;

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _pickedBytes = bytes);
    widget.onChanged(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFFFF6F0),
          border: Border.all(color: const Color(0xFFFFE0C7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_pickedBytes != null)
              Image.memory(_pickedBytes!, fit: BoxFit.cover)
            else
              PetNetworkImage(
                imageUrl: widget.initialImageUrl,
                fit: BoxFit.cover,
                iconSize: 48,
              ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF9E68),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_a_photo,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
