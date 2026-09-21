import 'package:flutter/material.dart';

import '../utils/pet_tags.dart';

/// ปุ่มเลือกแท็กนิสัย ใช้ชุดเดียวกันทั้งฝั่งผู้ใช้และฝั่งสัตว์เลี้ยง
/// เลือกได้สูงสุด [maxTagSelection] แท็ก พอครบแล้วปุ่มที่ยังไม่ได้เลือกจะกดไม่ได้
class TagSelector extends StatelessWidget {
  const TagSelector({
    super.key,
    required this.selectedIds,
    required this.onToggle,
    this.enabled = true,
    this.backgroundColor = Colors.white,
  });

  final List<String> selectedIds;
  final ValueChanged<String> onToggle;
  final bool enabled;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final reachedMax = selectedIds.length >= maxTagSelection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: petTags.map((tag) {
            final isSelected = selectedIds.contains(tag.id);
            final canTap = enabled && (isSelected || !reachedMax);
            return ChoiceChip(
              label: Text(tag.label,
                  style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (canTap ? Colors.black87 : Colors.black38),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal)),
              selected: isSelected,
              onSelected: canTap ? (_) => onToggle(tag.id) : null,
              selectedColor: const Color(0xFFFF9E68),
              backgroundColor: backgroundColor,
              disabledColor: isSelected
                  ? const Color(0xFFFF9E68).withValues(alpha: 0.65)
                  : backgroundColor,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          'เลือกได้สูงสุด $maxTagSelection แท็ก (เลือกแล้ว ${selectedIds.length})',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
