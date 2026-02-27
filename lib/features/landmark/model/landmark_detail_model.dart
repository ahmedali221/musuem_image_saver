import 'gallery_item_model.dart';
import 'landmark_file_model.dart';

// Nested project summary inside a landmark detail response
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

// Full response from GET /api/landmarks/{id}
class LandmarkDetailModel {
  final int id;
  final int projectId;
  final LandmarkProjectRef? project;
  final String name;
  final String slug;
  final List<double> centerPoint;
  final List<List<double>> area;
  final String coverImageUrl;
  final String status;
  final List<GalleryItemModel> gallery;
  final List<LandmarkFileModel> files;

  const LandmarkDetailModel({
    required this.id,
    required this.projectId,
    this.project,
    required this.name,
    required this.slug,
    required this.centerPoint,
    required this.area,
    required this.coverImageUrl,
    required this.status,
    required this.gallery,
    required this.files,
  });

  factory LandmarkDetailModel.fromJson(Map<String, dynamic> json) {
    // center_point is [lat, lng]
    final rawCenter = json['center_point'] as List<dynamic>? ?? [];
    final centerPoint = rawCenter.map((e) => (e as num).toDouble()).toList();

    // area is [[lat, lng], [lat, lng], ...]
    final rawArea = json['area'] as List<dynamic>? ?? [];
    final area = rawArea
        .map(
          (point) => (point as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList(),
        )
        .toList();

    // Gallery items
    final rawGallery = json['gallery'] as List<dynamic>? ?? [];
    final gallery = rawGallery
        .map((e) => GalleryItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // File attachments
    final rawFiles = json['files'] as List<dynamic>? ?? [];
    final files = rawFiles
        .map((e) => LandmarkFileModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return LandmarkDetailModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      project: json['project'] != null
          ? LandmarkProjectRef.fromJson(json['project'] as Map<String, dynamic>)
          : null,
      name: json['name'] as String,
      slug: json['slug'] as String,
      centerPoint: centerPoint,
      area: area,
      coverImageUrl: json['cover_image_url'] as String,
      status: json['status'] as String,
      gallery: gallery,
      files: files,
    );
  }
}
