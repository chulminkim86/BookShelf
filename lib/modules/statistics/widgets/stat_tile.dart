import 'package:flutter/material.dart';
import '../../../app_theme.dart';

/// 큰 숫자 하나를 강조해서 보여주는 통계 타일 (총 보유 권수 등).
/// 차트가 아니라 "헤드라인 숫자" — dataviz 원칙상 굳이 그래프로 그리지 않는다.
class StatTile extends StatelessWidget {
  final String label;
  final String value;

  const StatTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
