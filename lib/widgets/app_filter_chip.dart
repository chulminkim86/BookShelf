import 'package:flutter/material.dart';
import '../app_theme.dart';

/// 알약(pill) 모양 필터 버튼 템플릿.
/// 상태(색): 선택 = Primary(파란 테두리+글씨) / 선택 안 됨 = Neutral(회색 테두리+검정 글씨). 배경은 항상 흰색.
/// 크기: regular(기본) / small(장르처럼 촘촘하게 여러 개 늘어놓을 때).
enum AppChipSize { regular, small }

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final AppChipSize size;

  // design.md에 테두리 두께 토큰은 없어서, 이 컴포넌트 안에서만 쓰는 값으로 둠.
  static const _borderWidthSelected = 1.6;
  static const _borderWidthDefault = 1.2;
  static const _borderWidthSelectedSmall = 1.3;
  static const _borderWidthDefaultSmall = 1.0;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.size = AppChipSize.regular,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.ink;
    final isSmall = size == AppChipSize.small;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? AppSpacing.md : AppSpacing.lg,
          vertical: isSmall ? 8 : AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: isSmall
                ? (selected ? _borderWidthSelectedSmall : _borderWidthDefaultSmall)
                : (selected ? _borderWidthSelected : _borderWidthDefault),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonLabel.copyWith(
            color: color,
            fontSize: isSmall ? 13 : 16,
          ),
        ),
      ),
    );
  }
}
