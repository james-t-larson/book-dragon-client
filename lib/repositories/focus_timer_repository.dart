import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/tourney.dart';

class FocusTimerRepository {
  final http.Client _httpClient;

  FocusTimerRepository({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Completes a focus session and returns the rewards/progress.
  Future<FocusTimerResponse> completeSession({
    required String token,
    required int bookId,
    required int minutes,
    required int currentPage,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('${AppConfig.baseUrl}/focus_timer_complete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'book_id': bookId,
        'minutes': minutes,
        'current_page': currentPage,
      }),
    );

    if (response.statusCode == 200) {
      return FocusTimerResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to complete focus session: ${response.statusCode}');
    }
  }
}
