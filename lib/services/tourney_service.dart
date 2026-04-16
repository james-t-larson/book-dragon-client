import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/tourney.dart';

/// Exception thrown on 401 responses so callers can redirect to login.
class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = 'Unauthorized']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// HTTP service for all tourney-related API calls.
///
/// Every request includes the user's Bearer token.  A 401 response throws
/// [UnauthorizedException] so the ViewModel / UI can redirect to login.
class TourneyService {
  final String token;

  /// Optional [http.Client] for testability; defaults to a new instance.
  final http.Client _client;

  TourneyService({required this.token, http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  void _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }
  }

  /// Fetches tourney configuration constants (dropdown options).
  ///
  /// Calls `GET /constants`.
  Future<TourneyConfig> getConstants() async {
    final response = await _client.get(
      Uri.parse('${AppConfig.baseUrl}/constants'),
      headers: _headers,
    );
    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      return TourneyConfig.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to load tourney constants (${response.statusCode})');
  }

  /// Gets the user's active tourney, or `null` if none exists.
  ///
  /// Calls `GET /tourney`. A 404 is treated as "no active tourney".
  Future<Tourney?> getActiveTourney() async {
    final response = await _client.get(
      Uri.parse('${AppConfig.baseUrl}/tourney'),
      headers: _headers,
    );
    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      return Tourney.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    if (response.statusCode == 404) {
      return null; // no active challenge
    }
    throw Exception('Failed to fetch active tourney (${response.statusCode})');
  }

  /// Joins an existing tourney via invite code.
  ///
  /// Calls `POST /join_tourney`.
  Future<Tourney> joinTourney(String inviteCode) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.baseUrl}/join_tourney'),
      headers: _headers,
      body: jsonEncode(JoinTourneyRequest(inviteCode: inviteCode).toJson()),
    );
    _checkUnauthorized(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Tourney.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to join tourney (${response.statusCode})');
  }

  /// Creates a brand-new tourney.
  ///
  /// Calls `POST /tourney`.
  Future<Tourney> createTourney(CreateTourneyRequest request) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.baseUrl}/tourney'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    _checkUnauthorized(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Tourney.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to create tourney (${response.statusCode})');
  }
}
