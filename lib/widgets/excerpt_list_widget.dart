import 'package:flutter/material.dart';
import 'dart:io';
import '../models/excerpt_model.dart';
import '../screens/excerpt_detail_screen.dart';

class ExcerptListWidget extends StatelessWidget {
  final List<Excerpt> excerpts;
  final Function(int) onDelete;

  const ExcerptListWidget({
    Key? key,
    required this.excerpts,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (excerpts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.format_quote,
                size: 48,
                color: Color(0xFF757472),
              ),
              SizedBox(height: 8),
              Text(
                '아직 발췌문이 없습니다',
                style: TextStyle(color: Colors.black54),
              ),
              Text(
                '우측 상단 + 버튼을 눌러 추가하세요',
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: excerpts.length,
      itemBuilder: (context, index) {
        final excerpt = excerpts[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExcerptDetailScreen(excerpt: excerpt),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 썸네일 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(excerpt.imagePath),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: const Color(0xFFEDEDED),
                          child: const Icon(
                            Icons.broken_image,
                            color: Color(0xFF757472),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 텍스트 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 발췌문 텍스트 (최대 3줄)
                        Text(
                          excerpt.editedText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 하단 정보 (페이지, 날짜)
                        Row(
                          children: [
                            if (excerpt.pageNumber != null) ...[
                              const Icon(
                                Icons.book,
                                size: 14,
                                color: Color(0xFF757472),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'p.${excerpt.pageNumber}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Color(0xFF757472),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(excerpt.dateAdded),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 삭제 버튼
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: const Color(0xFF757472),
                    onPressed: () {
                      _showDeleteConfirmDialog(context, index);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('발췌문 삭제'),
        content: const Text('이 발췌문을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(index);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
