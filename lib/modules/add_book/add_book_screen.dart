import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../data/book.dart';
import '../../widgets/app_section_card.dart';
import '../book_detail/book_detail_screen.dart';
import 'barcode_scan_screen.dart';

/// 새 책 추가 진입 화면. 카메라로 스캔하거나, 직접 제목/저자를 입력해서
/// 책 상세 화면(추가 모드)으로 넘어간다. 실제 저장은 책 상세의 "저장" 버튼에서 이뤄진다.
class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  bool _manualMode = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final saved = await Navigator.of(context).push<Book>(
      MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
    );
    if (saved != null && mounted) {
      Navigator.of(context).pop(saved);
    }
  }

  Future<void> _submitManual() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final book = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      author: _authorController.text.trim().isEmpty
          ? '저자 미상'
          : _authorController.text.trim(),
      placeholderColor: Book.colorForTitle(title),
      purchaseDate: DateTime.now(),
    );

    final saved = await Navigator.of(context).push<Book>(
      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book, isNew: true)),
    );
    if (saved != null && mounted) {
      Navigator.of(context).pop(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('새 책 추가')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _scanBarcode,
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text('카메라로 바코드 스캔', style: AppTextStyles.buttonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _manualMode = !_manualMode),
                child: Text(
                  _manualMode ? '접기' : '또는 직접 입력하기',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
            ),
            if (_manualMode) ...[
              const SizedBox(height: AppSpacing.sm),
              AppSectionCard(
                label: '제목',
                child: SizedBox(
                  height: AppSizes.smallControlHeight,
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 13, color: AppColors.ink),
                    decoration: const InputDecoration(
                      hintText: '책 제목을 입력하세요',
                      hintStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.surface,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSectionCard(
                label: '저자',
                child: SizedBox(
                  height: AppSizes.smallControlHeight,
                  child: TextField(
                    controller: _authorController,
                    style: const TextStyle(fontSize: 13, color: AppColors.ink),
                    decoration: const InputDecoration(
                      hintText: '저자를 입력하세요',
                      hintStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.surface,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _submitManual,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.hairline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: const Text('다음', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
