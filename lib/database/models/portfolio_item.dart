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
  final String? photographerSurname;
  final String? photographerName;
  
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
    this.photographerSurname,
    this.photographerName,
  });
  
  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    final photographer = json['photographers'] as Map<String, dynamic>? ?? {};

    return PortfolioItem(
      id: json['id'],
      imageUrl: json['image_url'],
      title: json['title'],
      photographerId: json['photographer_id'],

      photographerName: photographer['name'],
      photographerSurname: photographer['surname'],

      genreTitle: json['genres']?['title'],
      moodTitle: json['moods']?['title'],
      locationTitle: json['locations']?['title'],
    );
  }
}