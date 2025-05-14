class Photographer {
  final int id;
  final DateTime createdAt;
  final String userId;
  final String? bio;
  final int cityId;
  final int? experience;
  final int price;
  final String? socialLinks;
  final String name; // Дополнительное поле для отображения
  final String? avatarUrl; // Дополнительное поле для отображения
  final String? contactInfo; // Дополнительное поле для отображения
  final String? description; // Дополнительное поле для отображения
  
  Photographer({
    required this.id,
    required this.createdAt,
    required this.userId,
    this.bio,
    required this.cityId,
    this.experience,
    required this.price,
    this.socialLinks,
    required this.name,
    this.avatarUrl,
    this.contactInfo,
    this.description,
  });
  
  factory Photographer.fromJson(Map<String, dynamic> json) {
    return Photographer(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      bio: json['bio'],
      cityId: json['city_id'] ?? 0,
      experience: json['experience'],
      price: json['price'] ?? 0,
      socialLinks: json['social_links'],
      name: json['users'] != null 
          ? '${json['users']['name']} ${json['users']['surname'] ?? ''}'
          : 'Неизвестный фотограф',
      avatarUrl: json['users'] != null ? json['users']['avatar_url'] : null,
      contactInfo: json['contact_info'],
      description: json['bio'],
    );
  }
}