class Location {
  final int id;
  final DateTime createdAt;
  final String title;
  
  Location({
    required this.id,
    required this.createdAt,
    required this.title,
  });
  
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      title: json['title'],
    );
  }
}