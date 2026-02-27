// A file attached to a landmark (audio, target image, json, etc.)
class LandmarkFileModel {
  final int id;
  final String fileType; // "audio" | "target" | "json" | ...
  final String originalName;
  final String downloadUrl;
  final String mimeType;
  final int fileSize;
  final String fileSizeHuman;
  final String? description;
  final String status;
  final String? statusFlag;

  const LandmarkFileModel({
    required this.id,
    required this.fileType,
    required this.originalName,
    required this.downloadUrl,
    required this.mimeType,
    required this.fileSize,
    required this.fileSizeHuman,
    this.description,
    required this.status,
    this.statusFlag,
  });

  factory LandmarkFileModel.fromJson(Map<String, dynamic> json) {
    return LandmarkFileModel(
      id: json['id'] as int,
      fileType: json['file_type'] as String,
      originalName: json['original_name'] as String,
      downloadUrl: json['download_url'] as String,
      mimeType: json['mime_type'] as String,
      fileSize: json['file_size'] as int,
      fileSizeHuman: json['file_size_human'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      statusFlag: json['status_flag'] as String?,
    );
  }

  // Handy icon helper used in the UI
  bool get isAudio => fileType == 'audio';
  bool get isImage => mimeType.startsWith('image/');
  bool get isJson => fileType == 'json';
  bool get isTarget => fileType == 'target';
}
