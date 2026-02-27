/// Represents the authenticated user returned by GET /api/user.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? preferredLanguage;
  final int? purchasedProjectsCount;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.preferredLanguage,
    this.purchasedProjectsCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
      purchasedProjectsCount: json['purchased_projects_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (emailVerifiedAt != null) 'email_verified_at': emailVerifiedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      if (purchasedProjectsCount != null)
        'purchased_projects_count': purchasedProjectsCount,
    };
  }
}
