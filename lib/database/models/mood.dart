class Mood {
  final int id;
  final DateTime createdAt;
  final String title;
  
  Mood({
    required this.id,
    required this.createdAt,
    required this.title,
  });
  
  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      title: json['title'],
    );
  }
}