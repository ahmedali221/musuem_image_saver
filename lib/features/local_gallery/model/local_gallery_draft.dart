/// A locally-stored draft of a gallery item tied to a project + landmark.
class LocalGalleryDraft {
  final int? id; // SQLite auto-increment; null before first insert
  final int projectId;
  final int landmarkId;
  final String projectName;
  final String landmarkName;
  final String name;
  final String partType;
  final String signatureType;
  final double? width;
  final double? height;
  final String description;
  final String notes;
  final List<String> imagePaths; // local file paths
  final String createdAt; // ISO-8601

  const LocalGalleryDraft({
    this.id,
    required this.projectId,
    required this.landmarkId,
    required this.projectName,
    required this.landmarkName,
    required this.name,
    required this.partType,
    required this.signatureType,
    this.width,
    this.height,
    required this.description,
    required this.notes,
    required this.imagePaths,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'project_id': projectId,
    'landmark_id': landmarkId,
    'project_name': projectName,
    'landmark_name': landmarkName,
    'name': name,
    'part_type': partType,
    'signature_type': signatureType,
    'width': width,
    'height': height,
    'description': description,
    'notes': notes,
    'image_paths': imagePaths.join('|'), // pipe-separated list
    'created_at': createdAt,
  };

  factory LocalGalleryDraft.fromMap(Map<String, dynamic> map) {
    final raw = map['image_paths'] as String? ?? '';
    return LocalGalleryDraft(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      landmarkId: map['landmark_id'] as int,
      projectName: map['project_name'] as String? ?? '',
      landmarkName: map['landmark_name'] as String? ?? '',
      name: map['name'] as String,
      partType: map['part_type'] as String,
      signatureType: map['signature_type'] as String,
      width: (map['width'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      description: map['description'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      imagePaths: raw.isEmpty ? [] : raw.split('|'),
      createdAt: map['created_at'] as String,
    );
  }

  LocalGalleryDraft copyWith({int? id}) => LocalGalleryDraft(
    id: id ?? this.id,
    projectId: projectId,
    landmarkId: landmarkId,
    projectName: projectName,
    landmarkName: landmarkName,
    name: name,
    partType: partType,
    signatureType: signatureType,
    width: width,
    height: height,
    description: description,
    notes: notes,
    imagePaths: imagePaths,
    createdAt: createdAt,
  );
}
