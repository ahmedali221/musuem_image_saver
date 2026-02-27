import 'package:musuem_image_saver/core/database/database_helper.dart';
import 'package:musuem_image_saver/features/local_gallery/model/local_gallery_draft.dart';

class LocalGalleryRepository {
  final DatabaseHelper _db;

  LocalGalleryRepository(this._db);

  Future<LocalGalleryDraft> saveDraft(LocalGalleryDraft draft) async {
    final db = await _db.database;
    final id = await db.insert('local_gallery_drafts', draft.toMap());
    return draft.copyWith(id: id);
  }

  Future<List<LocalGalleryDraft>> getAllDrafts() async {
    final db = await _db.database;
    final rows = await db.query(
      'local_gallery_drafts',
      orderBy: 'created_at DESC',
    );
    return rows.map(LocalGalleryDraft.fromMap).toList();
  }

  Future<void> deleteDraft(int id) async {
    final db = await _db.database;
    await db.delete('local_gallery_drafts', where: 'id = ?', whereArgs: [id]);
  }
}
