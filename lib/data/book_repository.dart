import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'book.dart';

/// 책 목록을 로컬(SharedPreferences)에 저장/조회하는 저장소.
/// ChangeNotifier라서, 서재/책상세 등 여러 화면이 동시에 최신 상태를 반영할 수 있다.
/// 앱 전체에서 하나만 쓰면 되므로 싱글턴으로 둔다 (상태관리 라이브러리 도입 전까지의 임시 방식).
class BookRepository extends ChangeNotifier {
  BookRepository._();
  static final BookRepository instance = BookRepository._();

  static const _prefsKey = 'books';

  List<Book> _books = [];
  bool _loaded = false;

  List<Book> get books => List.unmodifiable(_books);
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = json.decode(raw) as List;
      _books = list
          .map((e) => Book.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(_books.map((b) => b.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  Future<void> add(Book book) async {
    _books = [book, ..._books];
    notifyListeners();
    await _persist();
  }

  Future<void> update(Book book) async {
    _books = _books.map((b) => b.id == book.id ? book : b).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _books = _books.where((b) => b.id != id).toList();
    notifyListeners();
    await _persist();
  }
}
