import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_constants.dart';
import '../services/tourney_service.dart';

/// Repository for managing application-wide constants.
///
/// Implements caching logic:
/// 1. Check local storage (SharedPreferences).
/// 2. If present, return cached data.
/// 3. If missing, fetch from [TourneyService], cache it, and return.
class ConstantsRepository {
  static const String _cacheKey = 'app_constants_cache';
  
  final TourneyService _service;
  final SharedPreferences _prefs;

  ConstantsRepository({
    required TourneyService service,
    required SharedPreferences prefs,
  })  : _service = service,
        _prefs = prefs;

  /// Retrieves the application constants, using the cache if available.
  Future<AppConstants> getConstants({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedJson = _prefs.getString(_cacheKey);
      if (cachedJson != null) {
        try {
          return AppConstants.fromString(cachedJson);
        } catch (e) {
          // If decoding fails, we should proceed to fetch fresh data
        }
      }
    }

    // Fetch from API
    final tourneyConfig = await _service.getConstants();
    
    // In this specific implementation, TourneyService returns TourneyConfig,
    // but the repository wraps it into AppConstants for future-proofing.
    final constants = AppConstants(tourneyConfig: tourneyConfig);
    
    // Save to cache
    await _prefs.setString(_cacheKey, constants.toStringContent());
    
    return constants;
  }

  /// Clears the local constants cache.
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
  }
}
