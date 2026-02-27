import 'gallery_item_model.dart';
import 'landmark_file_model.dart';

// Nested project summary inside a landmark list/detail response
class LandmarkProjectRef {
  final int id;
  final String name;
  final String description;

  const LandmarkProjectRef({
    required this.id,
    required this.name,
    required this.description,
  });

  factory LandmarkProjectRef.fromJson(Map<String, dynamic> json) {
    return LandmarkProjectRef(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
    );
  }
}

// Unified model for both the list items and the detail response
class LandmarkModel {
  final int id;
  final int projectId;
  final String name;
  final String slug;
  final String coverImageUrl;
  final String status;

  // Fields that might be null depending on list vs detail API response
  final String? type;
  final String? duration;
  final String? description;
  final LandmarkProjectRef? project;
  final List<double>? centerPoint;
  final List<List<double>>? area;
  final List<GalleryItemModel>? gallery;
  final List<LandmarkFileModel>? files;
  final String? createdAt;
  final String? updatedAt;

  const LandmarkModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.slug,
    required this.coverImageUrl,
    required this.status,
    this.type,
    this.duration,
    this.description,
    this.project,
    this.centerPoint,
    this.area,
    this.gallery,
    this.files,
    this.createdAt,
    this.updatedAt,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    // center_point is [lat, lng]
    final rawCenter = json['center_point'] as List<dynamic>?;
    final centerPoint = rawCenter?.map((e) => (e as num).toDouble()).toList();

    // area is [[lat, lng], [lat, lng], ...]
    final rawArea = json['area'] as List<dynamic>?;
    final area = rawArea
        ?.map(
          (point) => (point as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList(),
        )
        .toList();

    // Gallery items
    final rawGallery = json['gallery'] as List<dynamic>?;
    final gallery = rawGallery
        ?.map((e) => GalleryItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // File attachments
    final rawFiles = json['files'] as List<dynamic>?;
    final files = rawFiles
        ?.map((e) => LandmarkFileModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return LandmarkModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      coverImageUrl: json['cover_image_url'] as String,
      status: json['status'] as String,
      type: json['type'] as String?,
      duration: json['duration']?.toString(),
      description: json['description'] as String?,
      project: json['project'] != null
          ? LandmarkProjectRef.fromJson(json['project'] as Map<String, dynamic>)
          : null,
      centerPoint: centerPoint,
      area: area,
      gallery: gallery,
      files: files,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
