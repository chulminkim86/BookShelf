import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../models/excerpt_model.dart';

class ExcerptDetailScreen extends StatelessWidget {
  final Excerpt excerpt;

  const ExcerptDetailScreen({Key? key, required this.excerpt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFC),
      appBar: AppBar(
        title: const Text('발췌문 상세'),
        backgroundColor: const Color(0xFF757472),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareExcerpt(context),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지 전체 표시
            Hero(
              tag: 'excerpt_${excerpt.id}',
              child: Image.file(
                File(excerpt.imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: const Color(0xFFEDEDED),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Color(0xFF757472),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 텍스트 내용
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 메타 정보
                  Row(
                    children: [
                      if (excerpt.pageNumber != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFEDEDED)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.book,
                                size: 16,
                                color: Color(0xFF757472),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'p.${excerpt.pageNumber}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFEDEDED)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Color(0xFF757472),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(excerpt.dateAdded),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 발췌문 텍스트
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
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
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.format_quote,
                              color: Color(0xFF757472),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '발췌문',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          excerpt.editedText,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // OCR 원본 텍스트 (수정된 경우만 표시)
                  if (excerpt.extractedText != excerpt.editedText) ...[
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: const Text(
                        'OCR 원본 텍스트',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEFEFC),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFEDEDED)),
                          ),
                          child: Text(
                            excerpt.extractedText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: excerpt.editedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('텍스트가 클립보드에 복사되었습니다')),
    );
  }

  void _shareExcerpt(BuildContext context) {
    // 향후 share 패키지를 사용하여 구현 가능
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능은 추후 추가될 예정입니다')),
    );
  }
}
