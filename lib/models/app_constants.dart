import 'dart:convert';

/// A single selectable option in a configuration dropdown.
class ConfigOption {
  final String label;
  final int value;

  const ConfigOption({required this.label, required this.value});

  factory ConfigOption.fromJson(Map<String, dynamic> json) {
    return ConfigOption(
      label: json['label'] as String,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}

/// Tournament-specific configuration.
class TourneyConfig {
  final List<ConfigOption> overallGoalDays;
  final List<ConfigOption> dailyGoalMinutes;

  const TourneyConfig({
    required this.overallGoalDays,
    required this.dailyGoalMinutes,
  });

  factory TourneyConfig.fromJson(Map<String, dynamic> json) {
    return TourneyConfig(
      overallGoalDays: (json['overall_goal_days'] as List)
          .map((e) => ConfigOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailyGoalMinutes: (json['daily_goal_minutes'] as List)
          .map((e) => ConfigOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'overall_goal_days': overallGoalDays.map((e) => e.toJson()).toList(),
        'daily_goal_minutes': dailyGoalMinutes.map((e) => e.toJson()).toList(),
      };
}

/// Global constants for the Book Dragon application.
/// 
/// Corresponds to the response from `GET /constants`.
class AppConstants {
  final TourneyConfig tourneyConfig;

  const AppConstants({required this.tourneyConfig});

  factory AppConstants.fromJson(Map<String, dynamic> json) {
    return AppConstants(
      tourneyConfig: TourneyConfig.fromJson(
        json['tourney_config'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'tourney_config': tourneyConfig.toJson(),
      };
  
  /// Helper to decode from a stored JSON string.
  factory AppConstants.fromString(String jsonString) {
    return AppConstants.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Helper to encode to a JSON string for storage.
  String toStringContent() => jsonEncode(toJson());
}
