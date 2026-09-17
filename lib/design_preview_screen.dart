import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'widgets/app_filter_chip.dart';

/// 디자인 템플릿(버튼, 카드 등)을 하나씩 정할 때 눈으로 확인하는 개발용 화면.
/// 실제 사용자 화면이 아니라 컴포넌트 검토용.
class DesignPreviewScreen extends StatefulWidget {
  const DesignPreviewScreen({super.key});

  @override
  State<DesignPreviewScreen> createState() => _DesignPreviewScreenState();
}

class _DesignPreviewScreenState extends State<DesignPreviewScreen> {
  int _selectedIndex = 0;
  final _labels = const ['전체 2', '승차권 2', '이용권', '정기권', 'N카드'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('컴포넌트 미리보기')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Text(
            '필터 버튼 (Pill Chip)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _labels.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                return AppFilterChip(
                  label: _labels[index],
                  selected: index == _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
