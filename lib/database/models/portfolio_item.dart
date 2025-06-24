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
  String? photographerSurname;
  String? photographerName;
  bool isFavorited = false;
  
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
    this.isFavorited = false,
  });
  
  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    var photographerData = json['photographers'] as Map<String, dynamic>? ?? {};
    var userData = photographerData['user_id'] as Map<String, dynamic>? ?? {};

    return PortfolioItem(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      photographerId: json['photographer_id'],
      imageUrl: json['image_url'],
      title: json['title'],
      genreId: json['genre_id'],
      moodId: json['mood_id'],
      locationId: json['location_id'],
      genreTitle: json['genres']?['title'],
      moodTitle: json['mood']?['title'],
      locationTitle: json['location']?['title'],
      photographerName: userData['name'],
      photographerSurname: userData['surname'],
      isFavorited: false,
    );
  }
}