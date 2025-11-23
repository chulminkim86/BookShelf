import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'book_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookShelf',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFF4F6DC),        // Beige (버튼)
          onPrimary: Colors.white,
          secondary: Color(0xFF757472),      // AppBar (변경됨)
          onSecondary: Colors.white,
          error: Color(0xFFB00020),
          onError: Colors.white,
          background: Color(0xFFFEFEFC),     // 배경 (변경됨)
          onBackground: Color(0xFF2D2D2D),
          surface: Color(0xFFB0A7A0),        // 카드 (변경됨)
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: Color(0xFFFEFEFC),
        cardColor: Color(0xFFB0A7A0),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// 책 모델
class Book {
  String id;
  String title;
  String author;
  String publisher;
  String isbn;
  String? coverUrl;
  String? source; // 'aladin' 또는 'google'
  
  // 새로운 필드들
  String? publishDate;      // 출판일
  String? purchaseDate;     // 구매일
  String? readingStatus;    // 'want', 'reading', 'done'
  int? rating;              // 0-5 별점
  String? category;         // 카테고리
  List<String>? tags;       // 태그
  String? memo;             // 메모

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.isbn,
    this.coverUrl,
    this.source,
    this.publishDate,
    this.purchaseDate,
    this.readingStatus,
    this.rating,
    this.category,
    this.tags,
    this.memo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publisher': publisher,
      'isbn': isbn,
      'coverUrl': coverUrl,
      'source': source,
      'publishDate': publishDate,
      'purchaseDate': purchaseDate,
      'readingStatus': readingStatus,
      'rating': rating,
      'category': category,
      'tags': tags,
      'memo': memo,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      publisher: json['publisher'],
      isbn: json['isbn'],
      coverUrl: json['coverUrl'],
      source: json['source'],
      publishDate: json['publishDate'],
      purchaseDate: json['purchaseDate'],
      readingStatus: json['readingStatus'],
      rating: json['rating'],
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      memo: json['memo'],
    );
  }
}

// 알라딘 API 키 (발급받은 키로 교체하세요!)
const String ALADIN_API_KEY = 'YOUR_ALADIN_API_KEY_HERE';

// 알라딘 API로 책 정보 가져오기
Future<Map<String, String>> fetchBookInfoFromAladin(String isbn) async {
  try {
    final url = Uri.parse(
      'https://www.aladin.co.kr/ttb/api/ItemLookUp.aspx'
      '?ttbkey=$ALADIN_API_KEY'
      '&itemIdType=ISBN'
      '&ItemId=$isbn'
      '&output=js'
      '&Version=20131101'
    );

    final response = await http.get(url).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('알라딘 API 타임아웃');
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['item'] != null && data['item'].isNotEmpty) {
        final item = data['item'][0];
        
        return {
          'title': item['title'] ?? '제목 없음',
          'author': item['author'] ?? '저자 미상',
          'publisher': item['publisher'] ?? '출판사 미상',
          'coverUrl': item['cover'] ?? '',
          'source': 'aladin',
        };
      }
    }
    
    throw Exception('알라딘에서 책을 찾을 수 없음');
  } catch (e) {
    print('알라딘 API 오류: $e');
    throw Exception('알라딘 API 오류');
  }
}

// Google Books API로 책 정보 가져오기
Future<Map<String, String>> fetchBookInfoFromGoogle(String isbn) async {
  try {
    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'
    );

    final response = await http.get(url).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('Google Books API 타임아웃');
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['totalItems'] > 0) {
        final book = data['items'][0]['volumeInfo'];
        
        return {
          'title': book['title'] ?? '제목 없음',
          'author': (book['authors'] != null && book['authors'].isNotEmpty)
              ? book['authors'].join(', ')
              : '저자 미상',
          'publisher': book['publisher'] ?? '출판사 미상',
          'coverUrl': book['imageLinks']?['thumbnail'] ?? '',
          'source': 'google',
        };
      }
    }
    
    throw Exception('Google Books에서 책을 찾을 수 없음');
  } catch (e) {
    print('Google Books API 오류: $e');
    throw Exception('Google Books API 오류');
  }
}

// 통합 API 호출 (알라딘 → Google 순서)
Future<Map<String, String>> fetchBookInfoCombined(String isbn) async {
  // 1. 알라딘 API 시도
  try {
    print('알라딘 API 시도 중...');
    final aladinResult = await fetchBookInfoFromAladin(isbn);
    print('알라딘 API 성공!');
    return aladinResult;
  } catch (e) {
    print('알라딘 실패, Google Books 시도 중...');
  }

  // 2. Google Books API 시도
  try {
    final googleResult = await fetchBookInfoFromGoogle(isbn);
    print('Google Books API 성공!');
    return googleResult;
  } catch (e) {
    print('Google Books도 실패');
    throw Exception('책 정보를 찾을 수 없습니다');
  }
}

// 메인 화면 (탭 네비게이션)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? booksJson = prefs.getString('books');
    
    if (booksJson != null) {
      final List<dynamic> booksList = json.decode(booksJson);
      setState(() {
        books = booksList.map((book) => Book.fromJson(book)).toList();
      });
    }
  }

  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String booksJson = json.encode(books.map((book) => book.toJson()).toList());
    await prefs.setString('books', booksJson);
  }

  void _onBookChanged() {
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      BookListScreen(
        books: books,
        onBooksChanged: _onBookChanged,
      ),
      StatisticsScreen(books: books),
    ];

    return Scaffold(
      backgroundColor: Color(0xFFFEFEFC),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFB0A7A0),
        selectedItemColor: Color(0xFF292929),
        unselectedItemColor: Color(0xFFEDEDED),
        elevation: 8,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '내 서재',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '통계',
          ),
        ],
      ),
    );
  }
}

// 통계 화면
class StatisticsScreen extends StatefulWidget {
  final List<Book> books;

  const StatisticsScreen({super.key, required this.books});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    // 출처별 통계
    final aladinCount = widget.books.where((b) => b.source == 'aladin').length;
    final googleCount = widget.books.where((b) => b.source == 'google').length;
    final manualCount = widget.books.where((b) => b.source == 'manual').length;
    final totalCount = widget.books.length;

    // 출판사별 통계 (Top 5)
    final publisherMap = <String, int>{};
    for (var book in widget.books) {
      if (book.publisher != '출판사 미상') {
        publisherMap[book.publisher] = (publisherMap[book.publisher] ?? 0) + 1;
      }
    }
    final topPublishers = publisherMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5Publishers = topPublishers.take(5).toList();

    // 저자별 통계 (Top 5)
    final authorMap = <String, int>{};
    for (var book in widget.books) {
      if (book.author != '저자 미상') {
        authorMap[book.author] = (authorMap[book.author] ?? 0) + 1;
      }
    }
    final topAuthors = authorMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5Authors = topAuthors.take(5).toList();

    // 최근 추가한 책 (최신 5권)
    final recentBooks = widget.books.reversed.take(5).toList();

    return Scaffold(
      backgroundColor: Color(0xFFFEFEFC),
      appBar: AppBar(
        title: const Text('통계'),
        backgroundColor: Color(0xFF757472),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: widget.books.isEmpty
          ? const Center(
              child: Text(
                '책을 추가하면\n통계가 표시됩니다 📊',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 총 책 권수
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.book, size: 40, color: Colors.blue),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              const Text(
                                '총 책 권수',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              Text(
                                '$totalCount권',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 출처별 분포
                  const Text(
                    '📊 출처별 분포',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildStatRow(
                            '알라딘',
                            aladinCount,
                            totalCount,
                            Colors.blue,
                          ),
                          const Divider(),
                          _buildStatRow(
                            'Google',
                            googleCount,
                            totalCount,
                            Colors.grey,
                          ),
                          const Divider(),
                          _buildStatRow(
                            '수동',
                            manualCount,
                            totalCount,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 출판사별 통계
                  if (top5Publishers.isNotEmpty) ...[
                    const Text(
                      '🏢 출판사별 TOP 5',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: top5Publishers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final publisher = entry.value;
                            return Column(
                              children: [
                                if (index > 0) const Divider(),
                                _buildRankRow(
                                  index + 1,
                                  publisher.key,
                                  publisher.value,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 저자별 통계
                  if (top5Authors.isNotEmpty) ...[
                    const Text(
                      '✍️ 저자별 TOP 5',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: top5Authors.asMap().entries.map((entry) {
                            final index = entry.key;
                            final author = entry.value;
                            return Column(
                              children: [
                                if (index > 0) const Divider(),
                                _buildRankRow(
                                  index + 1,
                                  author.key,
                                  author.value,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 최근 추가한 책
                  if (recentBooks.isNotEmpty) ...[
                    const Text(
                      '📚 최근 추가한 책',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    ...recentBooks.map((book) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: book.coverUrl != null && book.coverUrl!.isNotEmpty
                              ? Image.network(
                                  book.coverUrl!,
                                  width: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.book, size: 40);
                                  },
                                )
                              : const Icon(Icons.book, size: 40),
                          title: Text(
                            book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: book.source == 'aladin'
                                  ? Colors.blue.shade100
                                  : book.source == 'google'
                                      ? Colors.grey.shade300
                                      : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              book.source == 'aladin'
                                  ? '알라딘'
                                  : book.source == 'google'
                                      ? 'Google'
                                      : '수동',
                              style: TextStyle(
                                fontSize: 10,
                                color: book.source == 'aladin'
                                    ? Colors.blue.shade900
                                    : book.source == 'google'
                                        ? Colors.grey.shade800
                                        : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          Text(
            '$count권',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($percentage%)',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankRow(int rank, String name, int count) {
    final rankColors = [
      Colors.amber,
      Colors.grey.shade400,
      Colors.orange.shade300,
    ];
    final rankColor = rank <= 3 ? rankColors[rank - 1] : Colors.blue.shade100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count권',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// 책 목록 화면
class BookListScreen extends StatefulWidget {
  final List<Book> books;
  final VoidCallback onBooksChanged;

  const BookListScreen({
    super.key,
    required this.books,
    required this.onBooksChanged,
  });

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  // 책 목록 저장하기
  Future<void> _saveBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final String booksJson = json.encode(books.map((book) => book.toJson()).toList());
    await prefs.setString('books', booksJson);
  }

  // 책 추가하기
  void _addBook(Book book) async {
    final books = List<Book>.from(widget.books);
    books.add(book);
    await _saveBooks(books);
    widget.onBooksChanged();
  }

  // 책 삭제하기
  void _deleteBook(int index) async {
    final books = List<Book>.from(widget.books);
    books.removeAt(index);
    await _saveBooks(books);
    widget.onBooksChanged();
  }

  // 책 수정하기
  void _editBook(int index, Book updatedBook) async {
    final books = List<Book>.from(widget.books);
    books[index] = updatedBook;
    await _saveBooks(books);
    widget.onBooksChanged();
  }

  // 바코드 스캔 화면으로 이동
  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onBookScanned: _addBook,
        ),
      ),
    );
  }

  // CSV 내보내기 권한 요청
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      // Android 13 이상은 권한 불필요
      if (androidInfo.version.sdkInt >= 33) {
        return true;
      }
      
      // Android 12 이하는 저장소 권한 필요
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    
    return true;
  }

  // CSV 내보내기
  Future<void> _exportToCSV() async {
    if (widget.books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내보낼 책이 없습니다')),
      );
      return;
    }

    try {
      // 권한 확인
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장소 권한이 필요합니다')),
        );
        return;
      }

      // CSV 데이터 생성
      List<List<dynamic>> rows = [];
      rows.add(['제목', '저자', '출판사', 'ISBN', '출처']); // 헤더
      
      for (var book in widget.books) {
        rows.add([
          book.title,
          book.author,
          book.publisher,
          book.isbn,
          book.source ?? 'unknown',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      // Downloads 폴더에 저장
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final String filePath = '${directory!.path}/bookshelf_$timestamp.csv';
      
      final File file = File(filePath);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV 파일 저장 완료:\n${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV 내보내기 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFEFC),
      appBar: AppBar(
        title: const Text('내 서재'),
        backgroundColor: Color(0xFF757472),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportToCSV,
            tooltip: 'CSV로 내보내기',
          ),
        ],
      ),
      body: widget.books.isEmpty
          ? const Center(
              child: Text(
                '책을 추가해보세요!\n우측 하단 버튼을 눌러\n바코드를 스캔하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: widget.books.length,
              itemBuilder: (context, index) {
                final book = widget.books[index];
                return Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(
                            book: book,
                            onBookUpdated: (updatedBook) {
                              _editBook(index, updatedBook);
                            },
                          ),
                        ),
                      );
                    },
                    leading: book.coverUrl != null && book.coverUrl!.isNotEmpty
                        ? Image.network(
                            book.coverUrl!,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.book, size: 50);
                            },
                          )
                        : const Icon(Icons.book, size: 50),
                    title: Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,  // ← 여기 수정!
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '저자: ${book.author}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        Text(
                          '출판사: ${book.publisher}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        Text(
                          'ISBN: ${book.isbn}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        if (book.source != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: book.source == 'aladin' 
                                  ? Colors.blue.shade100 
                                  : book.source == 'google'
                                      ? Colors.grey.shade300
                                      : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              book.source == 'aladin' 
                                  ? '알라딘' 
                                  : book.source == 'google' 
                                      ? 'Google' 
                                      : '수동',
                              style: TextStyle(
                                fontSize: 10,
                                color: book.source == 'aladin' 
                                    ? Colors.blue.shade900 
                                    : book.source == 'google'
                                        ? Colors.grey.shade800
                                        : Colors.green.shade800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditDialog(index, book);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmDialog(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'manual_add',
            onPressed: _showManualAddDialog,
            backgroundColor: Color(0xFF6D6D6D),
            foregroundColor: Colors.white,
            elevation: 2,
            child: const Icon(Icons.add),
            tooltip: '수동 추가',
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'scan',
            onPressed: _openScanner,
            backgroundColor: Color(0xFF6D6D6D),
            foregroundColor: Colors.white,
            elevation: 2,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('바코드 스캔'),
          ),
        ],
      ),
    );
  }

  // 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('${widget.books[index].title}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              _deleteBook(index);
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 수동 추가 다이얼로그
  void _showManualAddDialog() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final publisherController = TextEditingController();
    final isbnController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('책 수동 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  hintText: '책 제목을 입력하세요',
                ),
              ),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: '저자',
                  hintText: '저자를 입력하세요',
                ),
              ),
              TextField(
                controller: publisherController,
                decoration: const InputDecoration(
                  labelText: '출판사',
                  hintText: '출판사를 입력하세요',
                ),
              ),
              TextField(
                controller: isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN (선택)',
                  hintText: 'ISBN을 입력하세요',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('제목을 입력하세요')),
                );
                return;
              }

              final newBook = Book(
                id: DateTime.now().toString(),
                title: titleController.text,
                author: authorController.text.isEmpty 
                    ? '저자 미상' 
                    : authorController.text,
                publisher: publisherController.text.isEmpty 
                    ? '출판사 미상' 
                    : publisherController.text,
                isbn: isbnController.text.isEmpty 
                    ? 'N/A' 
                    : isbnController.text,
                source: 'manual',
              );
              
              _addBook(newBook);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${newBook.title}이(가) 추가되었습니다')),
              );
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  // 수정 다이얼로그
  void _showEditDialog(int index, Book book) {
    final titleController = TextEditingController(text: book.title);
    final authorController = TextEditingController(text: book.author);
    final publisherController = TextEditingController(text: book.publisher);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('책 정보 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '제목'),
              ),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: '저자'),
              ),
              TextField(
                controller: publisherController,
                decoration: const InputDecoration(labelText: '출판사'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final updatedBook = Book(
                id: book.id,
                title: titleController.text,
                author: authorController.text,
                publisher: publisherController.text,
                isbn: book.isbn,
                coverUrl: book.coverUrl,
                source: book.source,
              );
              _editBook(index, updatedBook);
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}

// 바코드 스캐너 화면
class BarcodeScannerScreen extends StatefulWidget {
  final Function(Book) onBookScanned;

  const BarcodeScannerScreen({
    super.key,
    required this.onBookScanned,
  });

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('바코드 스캔'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _isProcessing = true;
                  _handleBarcode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // 스캔 가이드 오버레이
          Center(
            child: Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // 안내 텍스트
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: const Text(
                '책 뒷면의 바코드(ISBN)를 스캔하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 바코드 처리
  Future<void> _handleBarcode(String barcode) async {
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('책 정보 검색 중...'),
                SizedBox(height: 8),
                Text(
                  '알라딘 → Google Books',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 통합 API 호출
      final bookInfo = await fetchBookInfoCombined(barcode);

      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      // 책 정보 표시 및 저장 다이얼로그
      _showBookInfoDialog(barcode, bookInfo);
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      // 에러 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('오류'),
          content: Text('책 정보를 가져올 수 없습니다.\n\n$e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _isProcessing = false;
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  // 책 정보 확인 다이얼로그
  void _showBookInfoDialog(String isbn, Map<String, String> bookInfo) {
    final titleController = TextEditingController(text: bookInfo['title']);
    final authorController = TextEditingController(text: bookInfo['author']);
    final publisherController = TextEditingController(text: bookInfo['publisher']);
    final source = bookInfo['source'] ?? 'unknown';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('책 정보 확인'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: source == 'aladin' 
                    ? Colors.blue.shade100 
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                source == 'aladin' ? '알라딘' : 'Google',
                style: TextStyle(
                  fontSize: 12,
                  color: source == 'aladin' 
                      ? Colors.blue.shade900 
                      : Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (bookInfo['coverUrl']!.isNotEmpty)
                Image.network(
                  bookInfo['coverUrl']!,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.book, size: 100);
                  },
                ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '제목'),
              ),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: '저자'),
              ),
              TextField(
                controller: publisherController,
                decoration: const InputDecoration(labelText: '출판사'),
              ),
              const SizedBox(height: 8),
              Text('ISBN: $isbn', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _isProcessing = false;
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final book = Book(
                id: DateTime.now().toString(),
                title: titleController.text,
                author: authorController.text,
                publisher: publisherController.text,
                isbn: isbn,
                coverUrl: bookInfo['coverUrl'],
                source: source,
              );
              
              widget.onBookScanned(book);
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 스캐너 화면 닫기
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
