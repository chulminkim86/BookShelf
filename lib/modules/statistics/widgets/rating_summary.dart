import 'package:flutter/material.dart';
import '../../../app_theme.dart';

/// 평균 별점 — 숫자 + 별 5개(반올림해서 채움)로 보여주는 헤드라인 지표.
class RatingSummary extends StatelessWidget {
  final double average;

  const RatingSummary({super.key, required this.average});

  @override
  Widget build(BuildContext context) {
    final filled = average.round().clamp(0, 5);

    return Row(
      children: [
        Text(
          average.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Row(
          children: List.generate(5, (index) {
            final isFilled = index < filled;
            return Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 18,
              color: isFilled ? AppColors.primary : AppColors.muted,
            );
          }),
        ),
      ],
    );
  }
}
