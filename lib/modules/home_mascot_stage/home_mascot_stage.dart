import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app_theme.dart';

/// 홈 화면 하단 여백 전체를 채우는 자리.
/// 지금은 unDraw 무료 일러스트("Relaxed reading")로 임시로 채워둔 상태.
/// 나중에는 사용자가 읽은 책 장르에 따라 캐릭터 모습/성격이 성장하는
/// 기능(장르별 비주얼 변화)이 여기에 들어갈 예정 — 아직 미구현.
///
/// 이 폴더(lib/modules/home_mascot_stage/)가 이 기능의 전용 공간.
/// 관련 에셋은 assets/images/home_mascot_stage/ 에 모아둔다.
class HomeMascotStage extends StatelessWidget {
  const HomeMascotStage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SvgPicture.asset(
              'assets/images/home_mascot_stage/relaxed_reading.svg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            '임시 이미지 (unDraw) — 캐릭터 성장 기능 준비 중',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
