import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'package:musuem_image_saver/features/landmark/model/landmark_model.dart';
import 'package:musuem_image_saver/features/landmark/model/gallery_item_model.dart';
import 'landmark_detail_state.dart';
import '../landmark_repository.dart';

class LandmarkDetailCubit extends Cubit<LandmarkDetailState> {
  final LandmarkRepository _repository;

  LandmarkDetailCubit(this._repository) : super(LandmarkDetailInitial());

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<void> loadLandmark(int projectId, int landmarkId) async {
    emit(LandmarkDetailLoading());
    try {
      final landmark = await _repository.getLandmarkById(projectId, landmarkId);
      emit(LandmarkDetailLoaded(landmark));
    } catch (e) {
      emit(LandmarkDetailError('Failed to load landmark: $e'));
    }
  }

  // ── Create Gallery Item ───────────────────────────────────────────────────

  Future<void> addGalleryItem({
    required int projectId,
    required int landmarkId,
    required String name,
    required String partType,
    required String signatureType,
    String? width,
    String? height,
    required String description,
    required String notes,
    required List<XFile> images,
  }) async {
    final current = _currentLandmark;
    if (current == null) return;

    emit(GalleryActionLoading(current));
    try {
      final formData = FormData.fromMap({
        'name': name,
        'part_type': partType,
        'signature_type': signatureType,
        if (width != null && width.isNotEmpty)
          'width': double.tryParse(width) ?? width,
        if (height != null && height.isNotEmpty)
          'height': double.tryParse(height) ?? height,
        'description': description,
        'notes': notes,
      });

      for (final img in images) {
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(
              img.path,
              filename: img.name.isNotEmpty ? img.name : 'image.jpg',
            ),
          ),
        );
      }

      final newItem = await _repository.createGalleryItem(
        projectId,
        landmarkId,
        formData,
      );
      emit(
        GalleryActionSuccess(
          _withGallery(current, [...(current.gallery ?? []), newItem]),
          'Gallery item added',
        ),
      );
    } catch (e) {
      emit(GalleryActionError(current, 'Failed to add item: $e'));
    }
  }

  // ── Update Gallery Item ───────────────────────────────────────────────────

  Future<void> updateGalleryItem({
    required int projectId,
    required int landmarkId,
    required int itemId,
    required String name,
    required String partType,
    required String signatureType,
    String? width,
    String? height,
    required String description,
    required String notes,
    List<XFile>? newImages,
    List<int>? removeImageIds,
  }) async {
    final current = _currentLandmark;
    if (current == null) return;

    emit(GalleryActionLoading(current));
    try {
      final formData = FormData.fromMap({
        'name': name,
        'part_type': partType,
        'signature_type': signatureType,
        if (width != null && width.isNotEmpty)
          'width': double.tryParse(width) ?? width,
        if (height != null && height.isNotEmpty)
          'height': double.tryParse(height) ?? height,
        'description': description,
        'notes': notes,
      });

      if (removeImageIds != null) {
        for (final id in removeImageIds) {
          formData.fields.add(MapEntry('remove_images[]', id.toString()));
        }
      }
      if (newImages != null) {
        for (final img in newImages) {
          formData.files.add(
            MapEntry(
              'images[]',
              await MultipartFile.fromFile(
                img.path,
                filename: img.name.isNotEmpty ? img.name : 'image.jpg',
              ),
            ),
          );
        }
      }

      final updated = await _repository.updateGalleryItem(
        projectId,
        landmarkId,
        itemId,
        formData,
      );
      final newGallery = (current.gallery ?? [])
          .map((g) => g.id == updated.id ? updated : g)
          .toList();
      emit(
        GalleryActionSuccess(
          _withGallery(current, newGallery),
          'Gallery item updated',
        ),
      );
    } catch (e) {
      emit(GalleryActionError(current, 'Failed to update item: $e'));
    }
  }

  // ── Delete Gallery Item ───────────────────────────────────────────────────

  Future<void> deleteGalleryItem({
    required int projectId,
    required int landmarkId,
    required int itemId,
  }) async {
    final current = _currentLandmark;
    if (current == null) return;

    emit(GalleryActionLoading(current));
    try {
      await _repository.deleteGalleryItem(projectId, landmarkId, itemId);
      final newGallery = (current.gallery ?? [])
          .where((g) => g.id != itemId)
          .toList();
      emit(
        GalleryActionSuccess(
          _withGallery(current, newGallery),
          'Gallery item deleted',
        ),
      );
    } catch (e) {
      emit(GalleryActionError(current, 'Failed to delete item: $e'));
    }
  }

  // ── Download File ─────────────────────────────────────────────────────────

  Future<void> downloadFile({
    required int projectId,
    required int landmarkId,
    required int fileId,
    required String fileName,
  }) async {
    final current = _currentLandmark;
    if (current == null) return;

    // Use GalleryActionLoading to share the same spinner functionality (re-usable for arbitrary actions that shouldn't clear UI)
    emit(GalleryActionLoading(current));
    try {
      final path = await _repository.downloadFile(
        projectId,
        landmarkId,
        fileId,
        fileName,
      );
      emit(GalleryActionSuccess(current, 'File downloaded to $path'));
    } catch (e) {
      emit(GalleryActionError(current, 'Download failed: $e'));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  LandmarkModel? get _currentLandmark {
    final s = state;
    if (s is LandmarkDetailLoaded) return s.landmark;
    if (s is GalleryActionLoading) return s.landmark;
    if (s is GalleryActionSuccess) return s.landmark;
    if (s is GalleryActionError) return s.landmark;
    return null;
  }

  // Immutably swap out the gallery list while keeping all other fields.
  LandmarkModel _withGallery(LandmarkModel l, List<GalleryItemModel> gallery) {
    return LandmarkModel(
      id: l.id,
      projectId: l.projectId,
      name: l.name,
      slug: l.slug,
      coverImageUrl: l.coverImageUrl,
      status: l.status,
      type: l.type,
      duration: l.duration,
      description: l.description,
      project: l.project,
      centerPoint: l.centerPoint,
      area: l.area,
      createdAt: l.createdAt,
      updatedAt: l.updatedAt,
      files: l.files,
      gallery: gallery,
    );
  }
}
