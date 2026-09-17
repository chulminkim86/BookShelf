import 'package:flutter/material.dart';

/// 차트용 색상 토큰. dataviz 스킬의 검증된 기본 팔레트를 그대로 가져온 것
/// (CVD 안전성·명도 대비 등이 이미 검증된 순서 — 임의로 순서를 바꾸지 않는다).
///
/// - `categorical`: 정체성(장르 등)을 구분할 때, 항상 이 순서 그대로 사용.
///   9번째 이상의 항목은 새 색을 만들지 말고 `other`로 묶는다.
/// - `sequential`: 크기(매그니튜드) 비교용 단일 색 — 우리 브랜드 primary를 사용.
class AppChartColors {
  AppChartColors._();

  static const categorical = <Color>[
    Color(0xFF2A78D6), // 1 blue
    Color(0xFFEB6834), // 2 orange
    Color(0xFF1BAF7A), // 3 aqua
    Color(0xFFEDA100), // 4 yellow
    Color(0xFFE87BA4), // 5 magenta
    Color(0xFF008300), // 6 green
    Color(0xFF4A3AA7), // 7 violet
    Color(0xFFE34948), // 8 red
  ];

  /// 9번째 이상 항목을 묶는 "기타" 색.
  static const other = Color(0xFF898781);

  static const gridline = Color(0xFFE1E0D9);
}
