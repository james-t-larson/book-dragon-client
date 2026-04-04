class Book {
  final int id;
  final String title;
  final int readCount;

  Book({required this.id, required this.title, required this.readCount});

  Book copyWith({int? id, String? title, int? readCount}) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      readCount: readCount ?? this.readCount,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      readCount: json['read_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'read_count': readCount};
  }
}
