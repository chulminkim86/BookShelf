import 'package:flutter/material.dart';

// Book 클래스는 main.dart에서 import 해야 함
// import 'main.dart' 에서 Book 가져오기

class BookDetailScreen extends StatefulWidget {
  final dynamic book; // Book 타입
  final Function(dynamic) onBookUpdated;

  const BookDetailScreen({
    super.key,
    required this.book,
    required this.onBookUpdated,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late TextEditingController memoController;
  late TextEditingController categoryController;
  late TextEditingController tagController;
  late TextEditingController excerptController;
  
  String? selectedReadingStatus;
  int selectedRating = 0;
  DateTime? selectedPurchaseDate;
  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    
    // 기존 데이터 로드
    memoController = TextEditingController(text: widget.book.memo ?? '');
    categoryController = TextEditingController(text: widget.book.category ?? '');
    tagController = TextEditingController();
    excerptController = TextEditingController(text: widget.book.excerpt ?? '');
    
    selectedReadingStatus = widget.book.readingStatus ?? 'want';
    selectedRating = widget.book.rating ?? 0;
    
    if (widget.book.purchaseDate != null) {
      selectedPurchaseDate = DateTime.tryParse(widget.book.purchaseDate!);
    }
    
    if (widget.book.tags != null) {
      tags = List<String>.from(widget.book.tags!);
    }
  }

  @override
  void dispose() {
    memoController.dispose();
    categoryController.dispose();
    tagController.dispose();
    excerptController.dispose();
    super.dispose();
  }

  // 날짜 선택
  Future<void> _selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedPurchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF757472),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        selectedPurchaseDate = picked;
      });
    }
  }

  // 태그 추가
  void _addTag() {
    if (tagController.text.isNotEmpty) {
      setState(() {
        String tag = tagController.text.trim();
        if (!tag.startsWith('#')) {
          tag = '#$tag';
        }
        if (!tags.contains(tag)) {
          tags.add(tag);
        }
        tagController.clear();
      });
    }
  }

  // 태그 삭제
  void _removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  // 저장
  void _saveChanges() {
    // Book 객체 업데이트
    widget.book.readingStatus = selectedReadingStatus;
    widget.book.rating = selectedRating;
    widget.book.purchaseDate = selectedPurchaseDate?.toIso8601String().split('T')[0];
    widget.book.category = categoryController.text.isEmpty ? null : categoryController.text;
    widget.book.tags = tags.isEmpty ? null : tags;
    widget.book.memo = memoController.text.isEmpty ? null : memoController.text;
    widget.book.excerpt = excerptController.text.isEmpty ? null : excerptController.text;
    
    widget.onBookUpdated(widget.book);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFEFC),
      appBar: AppBar(
        title: const Text('책 상세'),
        backgroundColor: Color(0xFF757472),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveChanges,
            tooltip: '저장',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 표지 이미지
            if (widget.book.coverUrl != null && widget.book.coverUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.book.coverUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.book, size: 80, color: Colors.grey),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.book, size: 80, color: Colors.grey),
              ),
            
            const SizedBox(height: 24),
            
            // 기본 정보 카드
            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      widget.book.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 저자
                    _buildInfoRow('저자', widget.book.author),
                    const Divider(height: 16),
                    
                    // 출판사
                    _buildInfoRow('출판사', widget.book.publisher),
                    const Divider(height: 16),
                    
                    // 출판일
                    if (widget.book.publishDate != null)
                      _buildInfoRow('출판일', widget.book.publishDate!),
                    if (widget.book.publishDate != null)
                      const Divider(height: 16),
                    
                    // 구매일
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '읽기 시작한 날',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _selectPurchaseDate,
                          icon: Icon(Icons.calendar_today, size: 20),
                          label: Text(
                            selectedPurchaseDate != null
                                ? '${selectedPurchaseDate!.year}-${selectedPurchaseDate!.month.toString().padLeft(2, '0')}-${selectedPurchaseDate!.day.toString().padLeft(2, '0')}'
                                : '선택',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    
                    // ISBN
                    _buildInfoRow('ISBN', widget.book.isbn),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 읽기 상태 카드
            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '읽기 상태',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 읽기 상태 선택
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusChip('읽고 싶음', 'want'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatusChip('읽는 중', 'reading'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatusChip('읽음', 'done'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 별점
                    const Text(
                      '별점',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 카테고리 카드
            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '카테고리',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: categoryController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: '예: 기술서, 소설, 에세이',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 태그 카드
            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '태그',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 태그 입력
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tagController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: '태그 입력 (예: 프로그래밍)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Color(0xFF6D6D6D)),
                          onPressed: _addTag,
                        ),
                      ],
                    ),
                    
                    // 태그 목록
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor: Color(0xFFB0A7A0),
                            labelStyle: const TextStyle(color: Colors.white),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 메모 카드
            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '메모',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: memoController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: '책에 대한 메모를 입력하세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 발췌문 카드 (새로 추가!)
            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '발췌문',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: excerptController,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: '인상 깊었던 구절을 기록하세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80), // 하단 여백

            const SizedBox(height: 80), // 하단 여백
          ],
        ),
      ),
      
      // 하단 고정 버튼
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6D6D6D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('저장', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  // 읽기 상태 칩 위젯
  Widget _buildStatusChip(String label, String value) {
    final isSelected = selectedReadingStatus == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedReadingStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6D6D6D) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
