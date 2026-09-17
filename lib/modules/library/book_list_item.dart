import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../data/book.dart';

/// 서재 목록형(리스트) 배치의 책 한 줄.
/// 작은 표지(있으면 실제 이미지, 없으면 placeholder) + 제목/저자를 가로로 배치한다.
class BookListItem extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookListItem({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
        children: [
          Container(
            width: 48,
            height: 64,
            decoration: BoxDecoration(
              color: book.placeholderColor,
              borderRadius: BorderRadius.circular(AppRadius.xs),
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
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}
