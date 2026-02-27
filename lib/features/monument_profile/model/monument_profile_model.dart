import 'dart:convert';

/// Types of monument parts.
enum PartType {
  statue('Statue'),
  wall('Wall'),
  partOfWall('Part of wall'),
  targetMural('Target mural'),
  artifact('Artifact');

  final String label;
  const PartType(this.label);

  static PartType fromString(String value) {
    return PartType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PartType.statue,
    );
  }
}

/// Types of signatures / writing systems.
enum SignatureType {
  heroglific('Heroglific'),
  hieratic('Hieratic'),
  demotic('Demotic'),
  coptic('Coptic');

  final String label;
  const SignatureType(this.label);

  static SignatureType fromString(String value) {
    return SignatureType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SignatureType.heroglific,
    );
  }
}

class MonumentProfileModel {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final String notes;
  final PartType partType;
  final SignatureType signatureType;

  /// Only relevant when [partType] is [PartType.targetMural].
  final double? muralWidth;
  final double? muralHeight;

  final List<String> imagePaths;
  final DateTime createdAt;

  const MonumentProfileModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.notes,
    required this.partType,
    required this.signatureType,
    this.muralWidth,
    this.muralHeight,
    required this.imagePaths,
    required this.createdAt,
  });

  /// Convert to a Map for SQLite storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'description': description,
      'notes': notes,
      'partType': partType.name,
      'signatureType': signatureType.name,
      'muralWidth': muralWidth,
      'muralHeight': muralHeight,
      'imagePaths': jsonEncode(imagePaths),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from a SQLite Map row.
  factory MonumentProfileModel.fromMap(Map<String, dynamic> map) {
    return MonumentProfileModel(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      notes: map['notes'] as String,
      partType: PartType.fromString(map['partType'] as String),
      signatureType: SignatureType.fromString(map['signatureType'] as String),
      muralWidth: map['muralWidth'] as double?,
      muralHeight: map['muralHeight'] as double?,
      imagePaths: List<String>.from(jsonDecode(map['imagePaths'] as String)),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  MonumentProfileModel copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    String? notes,
    PartType? partType,
    SignatureType? signatureType,
    double? muralWidth,
    double? muralHeight,
    List<String>? imagePaths,
    DateTime? createdAt,
  }) {
    return MonumentProfileModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      partType: partType ?? this.partType,
      signatureType: signatureType ?? this.signatureType,
      muralWidth: muralWidth ?? this.muralWidth,
      muralHeight: muralHeight ?? this.muralHeight,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
