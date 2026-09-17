import 'package:flutter/material.dart';

/// design.md 토큰을 Flutter 상수로 옮긴 것.
/// Toss 앱처럼 밝은 배경 위에 Discord 분석에서 뽑은 강조색(Blurple)을 포인트로 쓴다.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF5865F2); // Blurple
  static const green = Color(0xFF35ED7E);
  static const magenta = Color(0xFFEC48BD);

  static const background = Color(0xFFF7F7FA);
  static const surface = Color(0xFFF0F1F5);

  /// 기본 "흰색". 순백(#FFFFFF) 대신 이 색을 카드/시트/버튼 배경 등 모든 곳에서 쓴다.
  static const card = Color(0xFFFAFAF8);

  static const ink = Color(0xFF1A1A1A);
  static const muted = Color(0xFF8B8D98);

  /// 섹션 사이 얇은 구분선용 (거의 안 보일 정도로 옅음).
  static const hairline = Color(0xFFE7E8EC);

  /// 버튼/입력창처럼 실제로 눈에 보여야 하는 테두리용 (hairline보다 진함).
  static const border = Color(0xFFD9DBE1);

  /// 에러 메시지 등 경고 텍스트용.
  static const danger = Color(0xFFE0245E);
}

class AppRadius {
  AppRadius._();

  static const xs = 6.0;
  static const sm = 12.0;
  static const md = 14.0;
  static const lg = 16.0;
  static const xl = 40.0;

  /// 알약(pill) 모양 버튼/칩처럼 완전히 둥근 모서리.
  static const full = 999.0;

  /// 입력 폼 등에서 라벨+필드를 한 덩어리로 감싸는 섹션 카드용.
  static const section = 10.0;
}

/// 한 줄짜리 입력 필드(보관장소, 날짜, 가격, 태그 입력 등)의 공통 높이.
/// small 버튼(AppChipSize.small)과 같은 높이감으로 맞춘 값.
class AppSizes {
  AppSizes._();

  static const smallControlHeight = 32.0;
}

/// 버튼류(필터 칩, 액션 버튼 등) 라벨에 공통으로 쓰는 텍스트 스타일.
/// 색상만 상황에 맞게 copyWith로 바꿔서 쓴다.
class AppTextStyles {
  AppTextStyles._();

  static const buttonLabel = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
}

class AppSpacing {
  AppSpacing._();

  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

const appFontFamily = 'Spoqa Han Sans Neo';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: appFontFamily,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: appFontFamily,
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
