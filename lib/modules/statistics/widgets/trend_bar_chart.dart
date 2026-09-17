import 'package:flutter/material.dart';
import '../../../app_theme.dart';

/// 시간(월/연도 등)에 따른 단일 지표 변화를 보여주는 세로 막대 차트.
/// 월별 읽은 책 수, 연도별 새 저자 수처럼 라벨 있는 시계열이면 뭐든 재사용한다.
/// 시간에 따른 단일 지표 변화라 한 가지 색만 쓴다.
class TrendBarChart extends StatelessWidget {
  final List<MapEntry<String, int>> data;
  final String emptyText;

  const TrendBarChart({super.key, required this.data, this.emptyText = '데이터가 없어요.'});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Text(
        emptyText,
        style: const TextStyle(color: AppColors.muted, fontSize: 13),
      );
    }
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    const chartHeight = 96.0;

    return SizedBox(
      height: chartHeight + 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((entry) {
          final ratio = maxValue == 0 ? 0.0 : entry.value / maxValue;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 18,
                  height: chartHeight * ratio.clamp(0.06, 1.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  entry.key,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
