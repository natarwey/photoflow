class Genre {
  final int id;
  final DateTime createdAt;
  final String title;
  
  Genre({
    required this.id,
    required this.createdAt,
    required this.title,
  });
  
  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      title: json['title'],
    );
  }
  
  // Геттер для совместимости с предыдущим кодом
  String get name => title;
}