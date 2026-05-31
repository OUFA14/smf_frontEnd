class User {
  final String id;
  final String username;
  final String email;
  final List<String> roles;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'roles': roles,
    };
  }

  bool isAdmin() => roles.contains('ADMIN');
  bool isUser() => roles.contains('USER');
  bool isOperator() => roles.contains('OPERATOR');
}

class LoginResponse {
  final String id;
  final String accessToken;
  final String refreshToken;
  final String time;

  LoginResponse({
    required this.id,
    required this.accessToken,
    required this.refreshToken,
    required this.time,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'] ?? '',
      accessToken: json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      time: json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'time': time,
    };
  }
}