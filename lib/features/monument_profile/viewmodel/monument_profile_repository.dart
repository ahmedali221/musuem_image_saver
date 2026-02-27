import 'dart:io';

import 'package:musuem_image_saver/features/monument_profile/model/monument_profile_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';

class MonumentProfileRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const _table = 'profiles';

  /// Fetch all profiles for a specific project, newest first.
  Future<List<MonumentProfileModel>> getProfilesByProject(
    String projectId,
  ) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: 'projectId = ?',
      whereArgs: [projectId],
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => MonumentProfileModel.fromMap(r)).toList();
  }

  /// Fetch a single profile by ID.
  Future<MonumentProfileModel?> getProfileById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return MonumentProfileModel.fromMap(rows.first);
  }

  /// Save a new profile under a project.
  Future<MonumentProfileModel> addProfile({
    required String projectId,
    required String name,
    required String description,
    required String notes,
    required PartType partType,
    required SignatureType signatureType,
    double? muralWidth,
    double? muralHeight,
    required List<String> tempImagePaths,
  }) async {
    final persistedPaths = await _persistImages(tempImagePaths);

    final profile = MonumentProfileModel(
      id: const Uuid().v4(),
      projectId: projectId,
      name: name,
      description: description,
      notes: notes,
      partType: partType,
      signatureType: signatureType,
      muralWidth: muralWidth,
      muralHeight: muralHeight,
      imagePaths: persistedPaths,
      createdAt: DateTime.now(),
    );

    final db = await _dbHelper.database;
    await db.insert(_table, profile.toMap());
    return profile;
  }

  /// Delete a profile and its images from disk.
  Future<void> deleteProfile(String id) async {
    final profile = await getProfileById(id);
    if (profile != null) {
      for (final path in profile.imagePaths) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    final db = await _dbHelper.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  // ── Helpers ──

  Future<List<String>> _persistImages(List<String> tempPaths) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/monument_images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final persisted = <String>[];
    for (final tempPath in tempPaths) {
      final fileName =
          '${const Uuid().v4()}_${tempPath.split(Platform.pathSeparator).last}';
      final destPath = '${imageDir.path}/$fileName';
      await File(tempPath).copy(destPath);
      persisted.add(destPath);
    }
    return persisted;
  }
}
