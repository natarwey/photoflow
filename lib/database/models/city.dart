class City {
  final int id;
  final DateTime createdAt;
  final String title;
  
  City({
    required this.id,
    required this.createdAt,
    required this.title,
  });
  
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      title: json['title'],
    );
  }
  
  // Геттер для совместимости с предыдущим кодом
  String get name => title;
}