class Photographer {
  final String id;
  final DateTime createdAt;
  final String userId;
  final String? bio;
  final int cityId;
  final int? experience;
  final int? price;
  final String? socialLinks;
  String? name;
  String? surname;
  String? avatarUrl;
  String? cityTitle;
  
  Photographer({
    required this.id,
    required this.createdAt,
    required this.userId,
    this.bio,
    required this.cityId,
    this.experience,
    this.price,
    this.socialLinks,
    this.name,
    this.surname,
    this.avatarUrl,
    this.cityTitle,
  });
  
  factory Photographer.fromJson(Map<String, dynamic> json) {
    return Photographer(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      bio: json['bio'],
      cityId: json['city_id'],
      experience: json['experience'],
      price: json['price'],
      socialLinks: json['social_links'],
    );
  }
}