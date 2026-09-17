import 'package:flutter/material.dart';
import '../app_theme.dart';

/// 이름표 + 가로 막대 + 값으로 이루어진 순위 리스트 템플릿.
/// 보관장소별 책 수, 태그별 분포처럼 "카테고리별 개수"를 비교할 때 공통으로 쓴다.
/// 각 행이 이미 이름으로 구분되므로 막대는 브랜드 색 하나로 통일한다
/// (정체성을 색으로 또 표현할 필요가 없음 — dataviz 원칙).
class AppRankedBarList extends StatelessWidget {
  final Map<String, int> data;
  final String emptyText;
  final int? maxItems;
  final double labelWidth;

  const AppRankedBarList({
    super.key,
    required this.data,
    this.emptyText = '아직 데이터가 없어요.',
    this.maxItems,
    this.labelWidth = 76,
  });

  @override
  Widget build(BuildContext context) {
    var entries = data.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (maxItems != null && entries.length > maxItems!) {
      entries = entries.sublist(0, maxItems!);
    }
    if (entries.isEmpty) {
      return Text(
        emptyText,
        style: const TextStyle(color: AppColors.muted, fontSize: 13),
      );
    }
    final maxValue = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Column(
      children: entries.map((entry) {
        final ratio = entry.value / maxValue;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: labelWidth,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12, color: AppColors.ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                        Container(
                          width: constraints.maxWidth * ratio,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: 24,
                child: Text(
                  '${entry.value}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
