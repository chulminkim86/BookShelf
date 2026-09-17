import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../data/book.dart';
import '../../data/book_repository.dart';
import '../../widgets/app_section_card.dart';
import 'widgets/date_picker_field.dart';
import 'widgets/genre_selector.dart';
import 'widgets/location_picker.dart';
import 'widgets/memo_field.dart';
import 'widgets/price_field.dart';
import 'widgets/star_rating.dart';
import 'widgets/tag_input.dart';

/// 기본 보관장소 목록. 화면 안에서 "+"로 추가한 장소는 이 목록에 더해진다.
const defaultBookLocations = <String>['서재', '거실', '현관 앞 책꽂이', '연구실'];

/// 책 상세 화면.
/// - `isNew: false`(기본) — 서재에서 기존 책을 탭했을 때. 값을 고쳐서 "저장"하면 덮어쓴다.
/// - `isNew: true` — 바코드 스캔/직접 추가 흐름에서 새 책을 저장할 때.
/// "저장"을 누르면 `BookRepository`에 실제로 저장되고, 저장된 `Book`을 반환하며 화면이 닫힌다.
class BookDetailScreen extends StatefulWidget {
  final Book book;
  final bool isNew;

  const BookDetailScreen({super.key, required this.book, this.isNew = false});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late int _rating = widget.book.rating;
  List<String> _locationOptions = List.of(defaultBookLocations);
  late String? _location = widget.book.location;

  // 날짜 필드 초기값은 기존 값이 있으면 그 값을, 없으면 오늘 날짜로 시작한다.
  late DateTime? _purchaseDate = widget.book.purchaseDate ?? DateTime.now();
  late DateTime? _startDate = widget.book.startDate ?? DateTime.now();
  late DateTime? _finishDate = widget.book.finishDate;

  late final _priceController =
      TextEditingController(text: widget.book.price?.toString() ?? '');

  List<BookGenre> _genres = List.of(defaultBookGenres);
  late String? _genre = widget.book.genre;
  late String? _subGenre = widget.book.subGenre;

  late List<String> _tags = List.of(widget.book.tags);
  late final _memoController = TextEditingController(text: widget.book.memo ?? '');

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (_location != null && !_locationOptions.contains(_location)) {
      _locationOptions = [..._locationOptions, _location!];
    }
    if (_genre != null && !_genres.any((g) => g.name == _genre)) {
      _genres = [..._genres, BookGenre(name: _genre!)];
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final price = int.tryParse(_priceController.text.replaceAll(',', ''));
    final updated = widget.book.copyWith(
      location: _location,
      purchaseDate: _purchaseDate,
      price: price,
      startDate: _startDate,
      finishDate: _finishDate,
      genre: _genre,
      subGenre: _subGenre,
      tags: _tags,
      rating: _rating,
      memo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
    );

    if (widget.isNew) {
      await BookRepository.instance.add(updated);
    } else {
      await BookRepository.instance.update(updated);
    }

    if (!mounted) return;
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: widget.isNew ? const Text('새 책 추가') : null),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 200,
                child: AspectRatio(
                  aspectRatio: 3 / 4.3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: book.placeholderColor,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      image: book.coverUrl != null
                          ? DecorationImage(
                              image: NetworkImage(book.coverUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: book.coverUrl == null
                        ? const Icon(
                            Icons.menu_book_outlined,
                            color: Colors.white70,
                            size: 48,
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              book.author,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.muted),
            ),
            if (book.publisher != null) ...[
              const SizedBox(height: 2),
              Text(
                book.publisher!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: AppSpacing.xl),

            AppSectionCard(
              label: '보관장소',
              child: LocationPicker(
                value: _location,
                options: _locationOptions,
                onChanged: (value) => setState(() => _location = value),
                onOptionsChanged: (options) =>
                    setState(() => _locationOptions = options),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppSectionCard(
                    label: '구매일자',
                    child: DatePickerField(
                      value: _purchaseDate,
                      onChanged: (value) => setState(() => _purchaseDate = value),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppSectionCard(
                    label: '가격',
                    child: PriceField(controller: _priceController),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppSectionCard(
                    label: '읽기 시작한 날',
                    child: DatePickerField(
                      value: _startDate,
                      onChanged: (value) => setState(() => _startDate = value),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppSectionCard(
                    label: '다 읽은 날',
                    child: DatePickerField(
                      value: _finishDate,
                      onChanged: (value) => setState(() => _finishDate = value),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            AppSectionCard(
              label: '별점',
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: StarRating(
                    rating: _rating,
                    onChanged: (value) => setState(() => _rating = value),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            AppSectionCard(
              label: '장르',
              child: GenreSelector(
                genres: _genres,
                selectedGenre: _genre,
                selectedSubGenre: _subGenre,
                onGenreChanged: (value) => setState(() => _genre = value),
                onSubGenreChanged: (value) => setState(() => _subGenre = value),
                onGenresChanged: (value) => setState(() => _genres = value),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            AppSectionCard(
              label: '태그',
              child: TagInput(
                tags: _tags,
                onChanged: (value) => setState(() => _tags = value),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            AppSectionCard(
              label: '메모',
              child: MemoField(controller: _memoController),
            ),
            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('저장', style: AppTextStyles.buttonLabel),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
