import 'package:flutter/material.dart';
import '../models/excerpt_model.dart';
import '../widgets/excerpt_list_widget.dart';
import 'add_excerpt_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final dynamic book;
  final Function(dynamic) onBookUpdated;

  const BookDetailScreen({
    Key? key,
    required this.book,
    required this.onBookUpdated,
  }) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late String _selectedStatus;
  late double _rating;
  late DateTime? _purchaseDate;
  late TextEditingController _categoryController;
  late TextEditingController _tagsController;
  late TextEditingController _memoController;
  late List<Excerpt> _excerpts;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.book.readingStatus;
    _rating = widget.book.rating;
    _purchaseDate = widget.book.purchaseDate;
    _categoryController = TextEditingController(text: widget.book.category ?? '');
    _tagsController = TextEditingController(text: widget.book.tags.join(', '));
    _memoController = TextEditingController(text: widget.book.memo ?? '');
    _excerpts = List.from(widget.book.excerpts);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _tagsController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedBook = widget.book.copyWith(
      readingStatus: _selectedStatus,
      rating: _rating,
      purchaseDate: _purchaseDate,
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      tags: _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      memo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
      excerpts: _excerpts,
    );

    widget.onBookUpdated(updatedBook);
    Navigator.pop(context);
  }

  Future<void> _addExcerpt() async {
    final result = await Navigator.push<Excerpt>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExcerptScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _excerpts.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('발췌문이 추가되었습니다')),
      );
    }
  }

  void _deleteExcerpt(int index) {
    setState(() {
      _excerpts.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('발췌문이 삭제되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFC),
      appBar: AppBar(
        title: const Text('책 상세 정보'),
        backgroundColor: const Color(0xFF757472),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 표지 (크게)
            Center(
              child: widget.book.coverUrl != null
                  ? Image.network(
                      widget.book.coverUrl!,
                      height: 300,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderCover();
                      },
                    )
                  : _buildPlaceholderCover(),
            ),
            const SizedBox(height: 24),

            // 기본 정보
            _buildInfoCard([
              _buildInfoRow('제목', widget.book.title),
              _buildInfoRow('저자', widget.book.author),
              _buildInfoRow('출판사', widget.book.publisher),
              _buildInfoRow('ISBN', widget.book.isbn),
              if (widget.book.publishDate != null)
                _buildInfoRow('출판일', widget.book.publishDate!),
              _buildInfoRow('정보 출처', widget.book.source),
            ]),
            const SizedBox(height: 24),

            // 읽기 상태
            const Text(
              '읽기 상태',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '읽을 예정', label: Text('읽을 예정')),
                ButtonSegment(value: '읽는 중', label: Text('읽는 중')),
                ButtonSegment(value: '읽음', label: Text('읽음')),
              ],
              selected: {_selectedStatus},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedStatus = newSelection.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Color(0xFF6D6D6D);
                    }
                    return Colors.white;
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return Colors.black;
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 별점
            const Text(
              '별점',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _rating.toStringAsFixed(1),
                    activeColor: const Color(0xFF6D6D6D),
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEDEDED)),
                  ),
                  child: Text(
                    _rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 구매일
            const Text(
              '구매일',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _purchaseDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF6D6D6D),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _purchaseDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEDEDED)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _purchaseDate != null
                          ? '${_purchaseDate!.year}-${_purchaseDate!.month.toString().padLeft(2, '0')}-${_purchaseDate!.day.toString().padLeft(2, '0')}'
                          : '날짜 선택',
                      style: TextStyle(
                        fontSize: 16,
                        color: _purchaseDate != null ? Colors.black : Colors.black38,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0xFF757472)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 카테고리
            const Text(
              '카테고리',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                hintText: '예: 소설, 자기계발, IT 등',
                hintStyle: TextStyle(color: Colors.black38),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 24),

            // 태그
            const Text(
              '태그',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                hintText: '쉼표로 구분 (예: 재미있음, 추천, 명작)',
                hintStyle: TextStyle(color: Colors.black38),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 24),

            // 메모
            const Text(
              '메모',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(
                hintText: '이 책에 대한 메모를 입력하세요',
                hintStyle: TextStyle(color: Colors.black38),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 5,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 32),

            // ========== 발췌문 섹션 ==========
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '발췌문 (${_excerpts.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: const Color(0xFF6D6D6D),
                  iconSize: 32,
                  onPressed: _addExcerpt,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ExcerptListWidget(
              excerpts: _excerpts,
              onDelete: _deleteExcerpt,
            ),
            const SizedBox(height: 32),
            // ========== 발췌문 섹션 끝 ==========
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      height: 300,
      width: 200,
      color: const Color(0xFFEDEDED),
      child: const Icon(
        Icons.book,
        size: 80,
        color: Color(0xFF757472),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
