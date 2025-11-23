class Excerpt {
  final String id;
  final String imagePath;
  final String extractedText;
  String editedText;
  final int? pageNumber;
  final DateTime dateAdded;

  Excerpt({
    required this.id,
    required this.imagePath,
    required this.extractedText,
    String? editedText,
    this.pageNumber,
    required this.dateAdded,
  }) : editedText = editedText ?? extractedText;

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'extractedText': extractedText,
      'editedText': editedText,
      'pageNumber': pageNumber,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory Excerpt.fromJson(Map<String, dynamic> json) {
    return Excerpt(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      extractedText: json['extractedText'] as String,
      editedText: json['editedText'] as String?,
      pageNumber: json['pageNumber'] as int?,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
    );
  }

  // 복사 메서드
  Excerpt copyWith({
    String? id,
    String? imagePath,
    String? extractedText,
    String? editedText,
    int? pageNumber,
    DateTime? dateAdded,
  }) {
    return Excerpt(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      editedText: editedText ?? this.editedText,
      pageNumber: pageNumber ?? this.pageNumber,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
