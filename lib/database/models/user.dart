class User {
  final String id;
  final DateTime createdAt;
  final String email;
  final String password;
  final String? surname;
  final String name;
  final String? avatarUrl;
  
  User({
    required this.id,
    required this.createdAt,
    required this.email,
    required this.password,
    this.surname,
    required this.name,
    this.avatarUrl,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      email: json['email'],
      password: json['password'],
      surname: json['surname'],
      name: json['name'],
      avatarUrl: json['avatar_url'],
    );
  }
}