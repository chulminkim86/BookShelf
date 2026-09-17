import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../widgets/app_chart_colors.dart';

/// 장르별 분포 도넛 차트 + 범례.
/// 카테고리 색은 항상 고정된 순서로 배정 (dataviz 검증 팔레트). 9번째부터는 "기타"로 묶는다.
class GenreDonutChart extends StatelessWidget {
  final Map<String, int> data;

  const GenreDonutChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.where((e) => e.value > 0).toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    if (total == 0) {
      return const Text(
        '아직 장르 데이터가 없어요.',
        style: TextStyle(color: AppColors.muted, fontSize: 13),
      );
    }

    final slices = <_Slice>[];
    for (var i = 0; i < entries.length; i++) {
      final color = i < AppChartColors.categorical.length
          ? AppChartColors.categorical[i]
          : AppChartColors.other;
      final label = i < AppChartColors.categorical.length ? entries[i].key : '기타';
      slices.add(_Slice(label: label, value: entries[i].value, color: color));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 108,
          height: 108,
          child: CustomPaint(
            painter: _DonutPainter(slices: slices, total: total),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const Text(
                    '권',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: slices.map((slice) {
              final percent = (slice.value / total * 100).round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: slice.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        slice.label,
                        style: const TextStyle(fontSize: 13, color: AppColors.ink),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$percent% (${slice.value})',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Slice {
  final String label;
  final int value;
  final Color color;

  _Slice({required this.label, required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_Slice> slices;
  final int total;

  _DonutPainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 16.0;
    const gap = 0.035; // 조각 사이 시각적 여백 (라디안)

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      final adjustedSweep = (sweep - gap).clamp(0.0, sweep);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle + gap / 2,
        adjustedSweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices || oldDelegate.total != total;
  }
}
