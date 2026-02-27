// A single image inside a gallery item
class GalleryImageModel {
  final int id;
  final String url;

  const GalleryImageModel({required this.id, required this.url});

  factory GalleryImageModel.fromJson(Map<String, dynamic> json) {
    return GalleryImageModel(
      id: json['id'] as int,
      url: json['url'] as String? ?? json['image_url'] as String? ?? '',
    );
  }
}

// Represents one gallery item inside a landmark
// Matches the POST body: { name, part_type, width?, height?, signature_type, description, notes }
class GalleryItemModel {
  final int id;
  final String name;
  final String
  partType; // statue | wall | part_of_wall | target_mural | artifact
  final String signatureType;
  final double? width;
  final double? height;
  final String description;
  final String notes;
  final List<GalleryImageModel> images;

  const GalleryItemModel({
    required this.id,
    required this.name,
    required this.partType,
    required this.signatureType,
    this.width,
    this.height,
    required this.description,
    required this.notes,
    required this.images,
  });

  factory GalleryItemModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? [];
    return GalleryItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      partType: json['part_type'] as String? ?? '',
      signatureType: json['signature_type'] as String? ?? '',
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      description: json['description'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      images: rawImages
          .map((e) => GalleryImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
