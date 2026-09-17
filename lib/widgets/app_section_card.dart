import 'package:flutter/material.dart';
import '../app_theme.dart';

/// 라벨 + 입력(또는 아무 콘텐츠)를 한 덩어리로 묶어서
/// radius 10, `AppColors.card`(#FAFAF8) 배경 사각형으로 감싸는 공용 템플릿.
/// 폼처럼 여러 섹션이 나열되는 화면(책 상세 등)에서 공통으로 쓴다.
class AppSectionCard extends StatelessWidget {
  final String? label;
  final Widget child;

  const AppSectionCard({super.key, this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.section),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          child,
        ],
      ),
    );
  }
}
