import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../app_theme.dart';

/// "책산(Tsundoku)" 시각화 — 다 읽은 책과 아직 안 읽은 책을 산 모양으로 비교.
/// 왼쪽 산(채워짐) = 읽음, 오른쪽 산(테두리만) = 아직 안 읽음. 높이는 권수 비율.
class TsundokuChart extends StatelessWidget {
  final int readCount;
  final int tbrCount;

  const TsundokuChart({super.key, required this.readCount, required this.tbrCount});

  @override
  Widget build(BuildContext context) {
    final total = readCount + tbrCount;
    if (total == 0) {
      return const Text(
        '아직 책 데이터가 없어요.',
        style: TextStyle(color: AppColors.muted, fontSize: 13),
      );
    }
    final percent = (readCount / total * 100).round();

    return Column(
      children: [
        SizedBox(
          height: 110,
          width: double.infinity,
          child: CustomPaint(
            painter: _MountainPainter(readCount: readCount, tbrCount: tbrCount),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Legend(color: AppColors.primary, filled: true, label: '읽음 $readCount권'),
            _Legend(color: AppColors.muted, filled: false, label: '안 읽음 $tbrCount권'),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '총 $total권 중 $percent% 완독',
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final bool filled;
  final String label;

  const _Legend({required this.color, required this.filled, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.ink)),
      ],
    );
  }
}

class _MountainPainter extends CustomPainter {
  final int readCount;
  final int tbrCount;

  _MountainPainter({required this.readCount, required this.tbrCount});

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = math.max(readCount, tbrCount).clamp(1, 1 << 30);
    final baseline = size.height;

    void drawMountain(double centerX, double halfWidth, int value, Paint paint) {
      final peakY = baseline - (value / maxValue) * (size.height - 8);
      final path = Path()
        ..moveTo(centerX - halfWidth, baseline)
        ..lineTo(centerX, peakY)
        ..lineTo(centerX + halfWidth, baseline)
        ..close();
      canvas.drawPath(path, paint);
    }

    final halfWidth = size.width * 0.22;

    final fillPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    drawMountain(size.width * 0.3, halfWidth, readCount, fillPaint);

    final strokePaint = Paint()
      ..color = AppColors.muted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    drawMountain(size.width * 0.7, halfWidth, tbrCount, strokePaint);

    final basePaint = Paint()
      ..color = AppColors.hairline
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, baseline), Offset(size.width, baseline), basePaint);
  }

  @override
  bool shouldRepaint(covariant _MountainPainter oldDelegate) {
    return oldDelegate.readCount != readCount || oldDelegate.tbrCount != tbrCount;
  }
}
