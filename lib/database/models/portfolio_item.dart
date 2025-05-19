class PortfolioItem {
  final int id;
  final DateTime createdAt;
  final int photographerId;
  final String imageUrl;
  final String title;
  final int genreId;
  final int? moodId;
  final int? locationId;
  String? genreTitle;
  String? moodTitle;
  String? locationTitle;
  
  PortfolioItem({
    required this.id,
    required this.createdAt,
    required this.photographerId,
    required this.imageUrl,
    required this.title,
    required this.genreId,
    this.moodId,
    this.locationId,
    this.genreTitle,
    this.moodTitle,
    this.locationTitle,
  });
  
  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      photographerId: json['photographer_id'],
      imageUrl: json['image_url'],
      title: json['title'],
      genreId: json['genre_id'],
      moodId: json['mood_id'],
      locationId: json['location_id'],
    );
  }
}