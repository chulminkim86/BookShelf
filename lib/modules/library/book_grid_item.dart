import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../data/book.dart';

/// 서재 이미지형(그리드) 배치의 책 한 칸.
/// 표지(있으면 실제 이미지, 없으면 placeholder) + 제목 + 저자 순으로 쌓는다.
class BookGridItem extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookGridItem({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4.3,
            child: Container(
              decoration: BoxDecoration(
                color: book.placeholderColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
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
                      size: 28,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
