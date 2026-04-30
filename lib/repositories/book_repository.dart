import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/book.dart';

class BookRepository {
  final http.Client _httpClient;

  BookRepository({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<List<Book>> fetchActiveBooks(String token) async {
    final response = await _httpClient.get(
      Uri.parse('${AppConfig.baseUrl}/books?currently_reading=true'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((b) => Book.fromJson(b)).toList();
    } else {
      throw Exception('Failed to fetch active books');
    }
  }

  Future<Book> addBook(String token, Book book) async {
    final response = await _httpClient.post(
      Uri.parse('${AppConfig.baseUrl}/books'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(book.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add book');
    }
  }
}
