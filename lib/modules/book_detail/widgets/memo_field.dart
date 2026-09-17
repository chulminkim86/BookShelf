import 'package:flutter/material.dart';
import '../../../app_theme.dart';

/// 여러 줄 메모 입력.
class MemoField extends StatelessWidget {
  final TextEditingController controller;

  const MemoField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 4,
      maxLines: 8,
      style: const TextStyle(fontSize: 13, color: AppColors.ink, height: 1.5),
      decoration: InputDecoration(
        hintText: '이 책에 대한 메모를 남겨보세요.',
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
