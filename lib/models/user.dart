class User {
  final int id;
  final String username;
  final String email;
  final DateTime createdAt;
  final int coins;
  final int? dragonId;
  final String? dragonName;
  final String? dragonColor;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.coins,
    this.dragonId,
    this.dragonName,
    this.dragonColor,
  });

  User copyWith({
    int? id,
    String? username,
    String? email,
    DateTime? createdAt,
    int? coins,
    int? dragonId,
    String? dragonName,
    String? dragonColor,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      coins: coins ?? this.coins,
      dragonId: dragonId ?? this.dragonId,
      dragonName: dragonName ?? this.dragonName,
      dragonColor: dragonColor ?? this.dragonColor,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      coins: json['coins'] ?? 0,
      dragonId: json['dragon_id'],
      dragonName: json['dragon_name'],
      dragonColor: json['dragon_color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'coins': coins,
      if (dragonId != null) 'dragon_id': dragonId,
      if (dragonName != null) 'dragon_name': dragonName,
      if (dragonColor != null) 'dragon_color': dragonColor,
    };
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}
