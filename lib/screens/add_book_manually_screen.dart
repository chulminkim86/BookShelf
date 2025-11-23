import 'package:flutter/material.dart';

class AddBookManuallyScreen extends StatefulWidget {
  const AddBookManuallyScreen({Key? key}) : super(key: key);

  @override
  State<AddBookManuallyScreen> createState() => _AddBookManuallyScreenState();
}

class _AddBookManuallyScreenState extends State<AddBookManuallyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _coverUrlController = TextEditingController();
  final TextEditingController _publishDateController = TextEditingController();

  @override
  void dispose() {
    _isbnController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _coverUrlController.dispose();
    _publishDateController.dispose();
    super.dispose();
  }

  void _saveBook() {
    if (_formKey.currentState!.validate()) {
      // Book 객체를 만들어서 반환
      final bookData = {
        'isbn': _isbnController.text.trim(),
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'publisher': _publisherController.text.trim(),
        'coverUrl': _coverUrlController.text.trim().isEmpty ? null : _coverUrlController.text.trim(),
        'publishDate': _publishDateController.text.trim().isEmpty ? null : _publishDateController.text.trim(),
      };

      Navigator.pop(context, bookData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFC),
      appBar: AppBar(
        title: const Text('책 수동 입력'),
        backgroundColor: const Color(0xFF757472),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveBook,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEDEDED)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF6D6D6D), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '제목과 저자는 필수 입력 항목입니다',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ISBN
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN',
                  hintText: '예: 9788936434267',
                  labelStyle: TextStyle(color: Colors.black54),
                  hintStyle: TextStyle(color: Colors.black38),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),

              // 제목 (필수)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목 *',
                  hintText: '책 제목을 입력하세요',
                  labelStyle: TextStyle(color: Colors.black54),
                  hintStyle: TextStyle(color: Colors.black38),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 저자 (필수)
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: '저자 *',
                  hintText: '저자명을 입력하세요',
                  labelStyle: TextStyle(color: Colors.black54),
                  hintStyle: TextStyle(color: Colors.black38),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '저자를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 출판사
              TextFormField(
                controller: _publisherController,
                decoration: const InputDecoration(
                  labelText: '출판사',
                  hintText: '출판사명을 입력하세요',
                  labelStyle: TextStyle(color: Colors.black54),
                  hintStyle: TextStyle(color: Colors.black38),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),

              // 출판일
              TextFormField(
                controller: _publishDateController,
                decoration: const InputDecoration(
                  labelText: '출판일',
                  hintText: '예: 2024-01-15',
                  labelStyle: TextStyle(color: Colors.black54),
                  hintStyle: TextStyle(color: Colors.black38),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),

              // 표지 이미지 URL
              TextFormField(
                controller: _coverUrlController,
                decoration: const InputDecoration(
                  labelText: '표지 이미지 URL (선택)',
                  hintText: 'https://...',
                  labelStyle: TextStyle(color: Colors.black54),
                  hintStyle: TextStyle(color: Colors.black38),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),

              // 저장 버튼
              ElevatedButton.icon(
                onPressed: _saveBook,
                icon: const Icon(Icons.save),
                label: const Text('저장', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D6D6D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
