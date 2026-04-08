class Book {
  final int id;
  final String title;
  final String author;
  final int totalPages;
  final int currentPage;
  final String genre;
  final int readCount;
  final bool reading;

  Book({
    required this.id,
    required this.title,
    this.author = '',
    this.totalPages = 0,
    this.currentPage = 0,
    this.genre = '',
    this.readCount = 0,
    this.reading = false,
  });

  Book copyWith({
    int? id,
    String? title,
    String? author,
    int? totalPages,
    int? currentPage,
    String? genre,
    int? readCount,
    bool? reading,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      genre: genre ?? this.genre,
      readCount: readCount ?? this.readCount,
      reading: reading ?? this.reading,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'] ?? '',
      totalPages: json['total_pages'] ?? 0,
      currentPage: json['current_page'] ?? 0,
      genre: json['genre'] ?? '',
      readCount: json['read_count'] ?? 0,
      reading: json['reading'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'total_pages': totalPages,
      'current_page': currentPage,
      'genre': genre,
      'read_count': readCount,
      'reading': reading,
    };
  }
}
