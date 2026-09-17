import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../app_theme.dart';
import '../../data/book.dart';
import '../../data/book_lookup_service.dart';
import '../book_detail/book_detail_screen.dart';

/// 카메라로 책 뒷면 바코드(ISBN)를 스캔 → 카카오/네이버/구글 순으로 조회 →
/// 결과를 채운 책 상세 화면(추가 모드)으로 넘어간다.
class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final _controller = MobileScannerController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _looksLikeIsbn(String value) {
    final digits = value.replaceAll('-', '');
    return RegExp(r'^97[89]\d{10}$').hasMatch(digits);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || !_looksLikeIsbn(code)) return;

    setState(() => _busy = true);
    await _lookupAndProceed(code.replaceAll('-', ''));
  }

  Future<void> _lookupAndProceed(String isbn) async {
    final result = await lookupBookByIsbn(isbn);

    if (!mounted) return;

    if (result == null) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('책 정보를 찾지 못했어요. 다시 스캔하거나 직접 입력해주세요.')),
      );
      return;
    }

    final book = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: result.title,
      author: result.author,
      isbn: result.isbn,
      publisher: result.publisher,
      coverUrl: result.coverUrl,
      placeholderColor: Book.colorForTitle(result.title),
      price: result.price,
      purchaseDate: DateTime.now(),
    );

    final saved = await Navigator.of(context).push<Book>(
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(book: book, isNew: true),
      ),
    );

    if (!mounted) return;
    if (saved != null) {
      Navigator.of(context).pop(saved);
    } else {
      setState(() => _busy = false);
    }
  }

  Future<void> _openManualEntry() async {
    final isbn = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('ISBN 직접 입력'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '978로 시작하는 13자리 숫자'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('조회'),
            ),
          ],
        );
      },
    );
    if (isbn == null || isbn.isEmpty || _busy) return;
    if (!_looksLikeIsbn(isbn)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('978/979로 시작하는 13자리 ISBN을 입력해주세요.')),
      );
      return;
    }
    setState(() => _busy = true);
    await _lookupAndProceed(isbn.replaceAll('-', ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('바코드 스캔'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _openManualEntry,
            icon: const Icon(Icons.keyboard_outlined),
            tooltip: 'ISBN 직접 입력',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          _ScanFrameOverlay(),
          if (_busy)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: AppSpacing.md),
                    Text('책 정보를 찾는 중...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            )
          else
            const Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Text(
                '책 뒷면 바코드를 네모 안에 맞춰주세요',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanFrameOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
