import 'package:flutter/material.dart';
import '../widgets/app_chart_colors.dart';

/// 앱 전체에서 쓰는 단일 책 모델. 서재/책 상세/추가 화면이 전부 이 모델을 공유한다.
class Book {
  final String id;
  final String title;
  final String author;
  final String? isbn;
  final String? publisher;
  final String? coverUrl;
  final Color placeholderColor;

  final String? location;
  final DateTime? purchaseDate;
  final int? price;
  final DateTime? startDate;
  final DateTime? finishDate;
  final String? genre;
  final String? subGenre;
  final List<String> tags;
  final int rating;
  final String? memo;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    this.publisher,
    this.coverUrl,
    required this.placeholderColor,
    this.location,
    this.purchaseDate,
    this.price,
    this.startDate,
    this.finishDate,
    this.genre,
    this.subGenre,
    this.tags = const [],
    this.rating = 0,
    this.memo,
  });

  /// 제목을 기준으로 카테고리 팔레트에서 색을 하나 골라 표지 placeholder로 쓴다.
  static Color colorForTitle(String title) {
    return AppChartColors.categorical[
        title.hashCode.abs() % AppChartColors.categorical.length];
  }

  Book copyWith({
    String? location,
    DateTime? purchaseDate,
    int? price,
    DateTime? startDate,
    DateTime? finishDate,
    String? genre,
    String? subGenre,
    List<String>? tags,
    int? rating,
    String? memo,
  }) {
    return Book(
      id: id,
      title: title,
      author: author,
      isbn: isbn,
      publisher: publisher,
      coverUrl: coverUrl,
      placeholderColor: placeholderColor,
      location: location ?? this.location,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      genre: genre ?? this.genre,
      subGenre: subGenre ?? this.subGenre,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      memo: memo ?? this.memo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'publisher': publisher,
      'coverUrl': coverUrl,
      'placeholderColor': placeholderColor.value,
      'location': location,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'price': price,
      'startDate': startDate?.toIso8601String(),
      'finishDate': finishDate?.toIso8601String(),
      'genre': genre,
      'subGenre': subGenre,
      'tags': tags,
      'rating': rating,
      'memo': memo,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      isbn: json['isbn'] as String?,
      publisher: json['publisher'] as String?,
      coverUrl: json['coverUrl'] as String?,
      placeholderColor: json['placeholderColor'] != null
          ? Color(json['placeholderColor'] as int)
          : colorForTitle(json['title'] as String),
      location: json['location'] as String?,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      price: json['price'] as int?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      finishDate: json['finishDate'] != null
          ? DateTime.parse(json['finishDate'] as String)
          : null,
      genre: json['genre'] as String?,
      subGenre: json['subGenre'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      rating: json['rating'] as int? ?? 0,
      memo: json['memo'] as String?,
    );
  }
}
