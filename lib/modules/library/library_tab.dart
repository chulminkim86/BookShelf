import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../data/book.dart';
import '../../data/book_repository.dart';
import '../book_detail/book_detail_screen.dart';
import 'book_grid_item.dart';
import 'book_list_item.dart';

enum LibraryViewMode { grid, list }

/// 서재 탭. 우측 상단 버튼으로 이미지형(그리드)/목록형 배치를 전환한다.
/// `BookRepository`를 구독해서, 새 책을 추가/수정하면 바로 반영된다.
class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  LibraryViewMode _viewMode = LibraryViewMode.grid;

  @override
  void initState() {
    super.initState();
    BookRepository.instance.load();
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == LibraryViewMode.grid
          ? LibraryViewMode.list
          : LibraryViewMode.grid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
            0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '서재',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              IconButton(
                onPressed: _toggleViewMode,
                icon: Icon(
                  _viewMode == LibraryViewMode.grid
                      ? Icons.view_list_outlined
                      : Icons.grid_view_outlined,
                  color: AppColors.ink,
                ),
                tooltip: _viewMode == LibraryViewMode.grid ? '목록형으로 보기' : '이미지형으로 보기',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: BookRepository.instance,
            builder: (context, _) {
              final repo = BookRepository.instance;
              if (!repo.isLoaded) {
                return const Center(child: CircularProgressIndicator());
              }
              if (repo.books.isEmpty) {
                return const Center(
                  child: Text(
                    '아직 등록된 책이 없어요.\n홈 화면의 + 버튼으로 책을 추가해보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                );
              }
              return _viewMode == LibraryViewMode.grid
                  ? _buildGrid(repo.books)
                  : _buildList(repo.books);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(List<Book> books) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.xl,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.52,
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return BookGridItem(
          book: book,
          onTap: () => _openDetail(context, book),
        );
      },
    );
  }

  Widget _buildList(List<Book> books) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      itemCount: books.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.hairline),
      itemBuilder: (context, index) {
        final book = books[index];
        return BookListItem(
          book: book,
          onTap: () => _openDetail(context, book),
        );
      },
    );
  }

  void _openDetail(BuildContext context, Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
    );
  }
}
