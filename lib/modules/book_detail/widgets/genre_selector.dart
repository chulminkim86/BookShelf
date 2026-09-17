import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../widgets/app_filter_chip.dart';

/// 장르 하나는 이름 + (있다면) 세부 장르 목록을 가진다.
class BookGenre {
  final String name;
  final List<String> subGenres;

  const BookGenre({required this.name, this.subGenres = const []});

  BookGenre copyWith({List<String>? subGenres}) {
    return BookGenre(name: name, subGenres: subGenres ?? this.subGenres);
  }
}

/// 기본 장르 목록. 세부 장르는 비어 있고, "+"로 직접 추가한다.
/// 캐릭터 성장 기능과도 연결될 예정이라 이름은 임의로 바꾸지 않는다.
const defaultBookGenres = <BookGenre>[
  BookGenre(name: '로맨스'),
  BookGenre(name: 'SF'),
  BookGenre(name: '추리/미스터리'),
  BookGenre(name: '판타지'),
  BookGenre(name: '자기계발'),
  BookGenre(name: '에세이/인문'),
  BookGenre(name: '역사'),
  BookGenre(name: '과학/교양'),
];

/// 장르(대분류) 단일 선택 + 선택된 장르에 세부 장르가 있으면 그것도 단일 선택.
/// "+"로 새 대분류 장르, 또는 선택된 장르 밑에 세부 장르를 추가할 수 있다.
class GenreSelector extends StatelessWidget {
  final List<BookGenre> genres;
  final String? selectedGenre;
  final String? selectedSubGenre;
  final ValueChanged<String?> onGenreChanged;
  final ValueChanged<String?> onSubGenreChanged;
  final ValueChanged<List<BookGenre>> onGenresChanged;

  const GenreSelector({
    super.key,
    required this.genres,
    required this.selectedGenre,
    required this.selectedSubGenre,
    required this.onGenreChanged,
    required this.onSubGenreChanged,
    required this.onGenresChanged,
  });

  Future<void> _addMainGenre(BuildContext context) async {
    final name = await _promptForText(
      context,
      title: '새 장르 추가',
      hint: '장르 이름',
    );
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    if (!genres.any((g) => g.name == trimmed)) {
      onGenresChanged([...genres, BookGenre(name: trimmed)]);
    }
    onGenreChanged(trimmed);
    onSubGenreChanged(null);
  }

  Future<void> _addSubGenre(BuildContext context, BookGenre parent) async {
    final name = await _promptForText(
      context,
      title: '${parent.name} 세부 장르 추가',
      hint: '세부 장르 이름',
    );
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    if (!parent.subGenres.contains(trimmed)) {
      final updated = genres.map((g) {
        if (g.name == parent.name) {
          return g.copyWith(subGenres: [...g.subGenres, trimmed]);
        }
        return g;
      }).toList();
      onGenresChanged(updated);
    }
    onSubGenreChanged(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final selected = selectedGenre == null
        ? null
        : genres.firstWhere(
            (g) => g.name == selectedGenre,
            orElse: () => BookGenre(name: selectedGenre!),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: genres.map((genre) {
            final isSelected = genre.name == selectedGenre;
            return AppFilterChip(
              label: genre.name,
              selected: isSelected,
              size: AppChipSize.small,
              onTap: () {
                onGenreChanged(isSelected ? null : genre.name);
                onSubGenreChanged(null);
              },
            );
          }).toList(),
        ),
        if (selected != null && selected.subGenres.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: selected.subGenres.map((sub) {
              final isSelected = sub == selectedSubGenre;
              return AppFilterChip(
                label: sub,
                selected: isSelected,
                size: AppChipSize.small,
                onTap: () => onSubGenreChanged(isSelected ? null : sub),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        // "새 장르 추가"와 "세부 장르 추가"는 같은 줄에 나란히 둔다.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AddChip(label: '장르', onTap: () => _addMainGenre(context)),
            if (selected != null) ...[
              const SizedBox(width: AppSpacing.xs),
              _AddChip(
                label: '세부 장르',
                onTap: () => _addSubGenre(context, selected),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// 장르 칩 줄 끝에 붙는 "+" 추가 버튼. small 칩과 같은 크기감으로 맞춘다.
class _AddChip extends StatelessWidget {
  final String? label;
  final VoidCallback onTap;

  const _AddChip({this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 15, color: AppColors.primary),
            if (label != null) ...[
              const SizedBox(width: 2),
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<String?> _promptForText(
  BuildContext context, {
  required String title,
  required String hint,
}) {
  final controller = TextEditingController();
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppRadius.xl),
        topRight: Radius.circular(AppRadius.xl),
      ),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    onSubmitted: (value) => Navigator.of(sheetContext).pop(value),
                    decoration: InputDecoration(
                      hintText: hint,
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: () => Navigator.of(sheetContext).pop(controller.text),
                  icon: const Icon(Icons.check, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
