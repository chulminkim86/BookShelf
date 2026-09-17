import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/app_ranked_bar_list.dart';
import '../../widgets/app_section_card.dart';
import 'mock_statistics_data.dart';
import 'widgets/genre_donut_chart.dart';
import 'widgets/rating_summary.dart';
import 'widgets/stat_tile.dart';
import 'widgets/trend_bar_chart.dart';
import 'widgets/tsundoku_chart.dart';

/// 통계 탭. 지금은 서재/책 상세와 실제로 연결되지 않은 샘플 데이터로
/// 레이아웃만 먼저 잡아둔 상태 (mock_statistics_data.dart 참고).
class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final priceFormatted = mockTotalSpent.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const Text(
          '통계',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppSectionCard(
                child: StatTile(label: '총 보유 권수', value: '$mockTotalBooks권'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppSectionCard(
                child: StatTile(label: '총 구매금액', value: '$priceFormatted원'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        AppSectionCard(
          child: StatTile(
            label: '가장 많이 구매한 달',
            value: '${mockMostPurchasedMonth.key} (${mockMostPurchasedMonth.value}권)',
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        AppSectionCard(
          label: '책산 (Tsundoku)',
          child: const TsundokuChart(
            readCount: mockReadCount,
            tbrCount: mockTbrCount,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        AppSectionCard(
          label: '장르별 분포',
          child: const GenreDonutChart(data: mockGenreDistribution),
        ),
        const SizedBox(height: AppSpacing.md),

        AppSectionCard(
          label: '평균 별점',
          child: const RatingSummary(average: mockAverageRating),
        ),
        const SizedBox(height: AppSpacing.md),

        AppSectionCard(
          label: '보관장소별 책 수',
          child: const AppRankedBarList(
            data: mockLocationCounts,
            emptyText: '아직 보관장소 데이터가 없어요.',
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        AppSectionCard(
          label: '태그별',
          child: const AppRankedBarList(
            data: mockTagCounts,
            emptyText: '아직 태그 데이터가 없어요.',
            maxItems: 6,
            labelWidth: 92,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        AppSectionCard(
          label: '가장 오래 안 읽고 쌓인 책',
          child: const AppRankedBarList(
            data: mockLongestOnTbr,
            emptyText: '쌓아둔 책이 없어요.',
            labelWidth: 110,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        AppSectionCard(
          label: '최근에 안 읽은 장르',
          child: const AppRankedBarList(
            data: mockGenreNeglectDays,
            emptyText: '아직 완독 기록이 없어요.',
            labelWidth: 92,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        AppSectionCard(
          label: '월별 읽은 책 수 추이',
          child: const TrendBarChart(
            data: mockMonthlyReadCounts,
            emptyText: '아직 완독 데이터가 없어요.',
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        AppSectionCard(
          label: '연도별 새 저자 수',
          child: const TrendBarChart(
            data: mockNewAuthorsByYear,
            emptyText: '아직 저자 데이터가 없어요.',
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        const Center(
          child: Text(
            '샘플 데이터입니다 (실제 서재 데이터 연결 전)',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
