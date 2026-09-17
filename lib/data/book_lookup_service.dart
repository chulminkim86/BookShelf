import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_keys.dart';

/// ISBN 조회 결과. 실제 값이 없는 필드는 null로 둔다.
class BookLookupResult {
  final String title;
  final String author;
  final String? publisher;
  final String? coverUrl;
  final int? price;
  final String isbn;
  final String source; // 'yes24' | 'kakao' | 'naver' | 'google'

  const BookLookupResult({
    required this.title,
    required this.author,
    this.publisher,
    this.coverUrl,
    this.price,
    required this.isbn,
    required this.source,
  });
}

String _stripHtml(String text) => text.replaceAll(RegExp(r'<[^>]*>'), '');

/// YES24 도서 검색 API로 ISBN 조회. ISBN 전용 파라미터가 없어서 `query`에 그대로 넣는다.
/// 문서: https://developers.yes24.com/api-doc/goods-item-list
Future<BookLookupResult?> _fetchFromYes24(String isbn) async {
  if (YES24_API_KEY.isEmpty) return null;
  final url = Uri.parse(
    'https://apis.yes24.com/v1/goods/itemList'
    '?query=$isbn&category=BOOK&pageSize=1',
  );
  final response = await http
      .get(url, headers: {'X-Api-Key': YES24_API_KEY})
      .timeout(const Duration(seconds: 6));

  if (response.statusCode != 200) return null;
  final data = json.decode(utf8.decode(response.bodyBytes));
  if (data['success'] != true) return null;

  final items = data['data']?['items'] as List?;
  if (items == null || items.isEmpty) return null;

  final item = items[0];
  final price = item['salePrice'] is int && item['salePrice'] > 0
      ? item['salePrice'] as int
      : (item['shopPrice'] as int?);

  return BookLookupResult(
    title: (item['title'] as String?)?.trim() ?? '제목 없음',
    author: item['author'] as String? ?? '저자 미상',
    publisher: item['publisher'] as String?,
    coverUrl: item['cover'] as String?,
    price: price,
    isbn: isbn,
    source: 'yes24',
  );
}

/// 카카오 도서 검색 API로 ISBN 조회.
Future<BookLookupResult?> _fetchFromKakao(String isbn) async {
  if (KAKAO_REST_API_KEY.isEmpty) return null;
  final url = Uri.parse(
    'https://dapi.kakao.com/v3/search/book?target=isbn&query=$isbn',
  );
  final response = await http
      .get(url, headers: {'Authorization': 'KakaoAK $KAKAO_REST_API_KEY'})
      .timeout(const Duration(seconds: 6));

  if (response.statusCode != 200) return null;
  final data = json.decode(utf8.decode(response.bodyBytes));
  final documents = data['documents'] as List?;
  if (documents == null || documents.isEmpty) return null;

  final item = documents[0];
  final authors = (item['authors'] as List?)?.join(', ') ?? '저자 미상';
  final price = item['sale_price'] is int && item['sale_price'] > 0
      ? item['sale_price'] as int
      : (item['price'] as int?);

  return BookLookupResult(
    title: (item['title'] as String?)?.trim() ?? '제목 없음',
    author: authors,
    publisher: item['publisher'] as String?,
    coverUrl: (item['thumbnail'] as String?)?.isEmpty ?? true
        ? null
        : item['thumbnail'] as String,
    price: price,
    isbn: isbn,
    source: 'kakao',
  );
}

/// 네이버 도서 검색 API(ISBN 전용 엔드포인트)로 조회.
Future<BookLookupResult?> _fetchFromNaver(String isbn) async {
  if (NAVER_CLIENT_ID.isEmpty || NAVER_CLIENT_SECRET.isEmpty) return null;
  final url = Uri.parse(
    'https://openapi.naver.com/v1/search/book_adv.json?d_isbn=$isbn',
  );
  final response = await http.get(url, headers: {
    'X-Naver-Client-Id': NAVER_CLIENT_ID,
    'X-Naver-Client-Secret': NAVER_CLIENT_SECRET,
  }).timeout(const Duration(seconds: 6));

  if (response.statusCode != 200) return null;
  final data = json.decode(utf8.decode(response.bodyBytes));
  final items = data['items'] as List?;
  if (items == null || items.isEmpty) return null;

  final item = items[0];
  final priceText = item['discount'] as String?;
  final price = (priceText != null && priceText.isNotEmpty)
      ? int.tryParse(priceText)
      : null;

  return BookLookupResult(
    title: _stripHtml(item['title'] as String? ?? '제목 없음'),
    author: _stripHtml(item['author'] as String? ?? '저자 미상').replaceAll('|', ', '),
    publisher: item['publisher'] as String?,
    coverUrl: (item['image'] as String?)?.isEmpty ?? true ? null : item['image'] as String,
    price: price,
    isbn: isbn,
    source: 'naver',
  );
}

/// Google Books API — 키 없이도 동작하는 마지막 폴백.
Future<BookLookupResult?> _fetchFromGoogle(String isbn) async {
  final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn');
  final response = await http.get(url).timeout(const Duration(seconds: 6));

  if (response.statusCode != 200) return null;
  final data = json.decode(utf8.decode(response.bodyBytes));
  if ((data['totalItems'] as int? ?? 0) <= 0) return null;

  final volumeInfo = data['items'][0]['volumeInfo'];
  final authors = (volumeInfo['authors'] as List?)?.join(', ') ?? '저자 미상';

  return BookLookupResult(
    title: volumeInfo['title'] as String? ?? '제목 없음',
    author: authors,
    publisher: volumeInfo['publisher'] as String?,
    coverUrl: volumeInfo['imageLinks']?['thumbnail'] as String?,
    price: null,
    isbn: isbn,
    source: 'google',
  );
}

/// YES24 → 카카오 → 네이버 → 구글북스 순으로 시도해서 첫 성공 결과를 돌려준다.
/// (네이버는 아직 키가 없어서 지금은 자동으로 건너뜀). 전부 실패하면 null.
Future<BookLookupResult?> lookupBookByIsbn(String isbn) async {
  for (final fetcher in [
    _fetchFromYes24,
    _fetchFromKakao,
    _fetchFromNaver,
    _fetchFromGoogle,
  ]) {
    try {
      final result = await fetcher(isbn);
      if (result != null) return result;
    } catch (_) {
      // 이 소스 실패, 다음 소스로 계속 진행.
    }
  }
  return null;
}
