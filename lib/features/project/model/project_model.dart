// Matches the actual API response from GET /api/projects and GET /api/projects/{id}
class ProjectModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String coverImageUrl;
  final String status;

  // Optional
  final String? type;
  final double price;
  final String createdAt;
  final String updatedAt;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.coverImageUrl,
    required this.status,
    this.type,
    this.price = 0.0,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      coverImageUrl: json['cover_image_url'] as String,
      status: json['status'] as String,
      type: json['type'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}
