import 'package:flutter/material.dart';
import '../../../app_theme.dart';

/// 0~5개 별점. 별을 누르면 그 개수로 별점이 설정된다.
class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const StarRating({super.key, required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final filled = starIndex <= rating;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => onChanged(starIndex),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? AppColors.primary : AppColors.muted,
            size: 28,
          ),
        );
      }),
    );
  }
}
