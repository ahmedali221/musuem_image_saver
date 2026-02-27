import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'local_gallery_state.dart';
import '../local_gallery_repository.dart';
import '../../model/local_gallery_draft.dart';
import 'package:musuem_image_saver/features/landmark/viewmodel/landmark_repository.dart';

class LocalGalleryCubit extends Cubit<LocalGalleryState> {
  final LocalGalleryRepository _repository;
  final LandmarkRepository _landmarkRepository;

  LocalGalleryCubit(this._repository, this._landmarkRepository)
    : super(LocalGalleryInitial());

  Future<void> loadDrafts() async {
    emit(LocalGalleryLoading());
    try {
      final drafts = await _repository.getAllDrafts();
      emit(LocalGalleryLoaded(drafts));
    } catch (e) {
      emit(LocalGalleryError(e.toString()));
    }
  }

  /// Saves a gallery item locally — no network call.
  Future<LocalGalleryDraft> saveDraft({
    required int projectId,
    required int landmarkId,
    required String projectName,
    required String landmarkName,
    required String name,
    required String partType,
    required String signatureType,
    String? width,
    String? height,
    required String description,
    required String notes,
    required List<XFile> images,
  }) async {
    final draft = LocalGalleryDraft(
      projectId: projectId,
      landmarkId: landmarkId,
      projectName: projectName,
      landmarkName: landmarkName,
      name: name,
      partType: partType,
      signatureType: signatureType,
      width: width != null && width.isNotEmpty ? double.tryParse(width) : null,
      height: height != null && height.isNotEmpty
          ? double.tryParse(height)
          : null,
      description: description,
      notes: notes,
      imagePaths: images.map((x) => x.path).toList(),
      createdAt: DateTime.now().toIso8601String(),
    );
    return await _repository.saveDraft(draft);
  }

  /// Uploads a draft to the server, then removes it from local storage.
  Future<void> uploadDraft(LocalGalleryDraft draft) async {
    final currentDrafts = _currentDrafts;

    // Mark this draft as uploading
    emit(LocalGalleryLoaded(currentDrafts, uploadingId: draft.id));

    try {
      final formData = FormData.fromMap({
        'name': draft.name,
        'part_type': draft.partType,
        'signature_type': draft.signatureType,
        if (draft.width != null) 'width': draft.width,
        if (draft.height != null) 'height': draft.height,
        'description': draft.description,
        'notes': draft.notes,
      });

      for (final path in draft.imagePaths) {
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(
              path,
              filename: path.split(Platform.pathSeparator).last,
            ),
          ),
        );
      }

      await _landmarkRepository.createGalleryItem(
        draft.projectId,
        draft.landmarkId,
        formData,
      );

      // Remove from local storage on success
      if (draft.id != null) await _repository.deleteDraft(draft.id!);
      final refreshed = await _repository.getAllDrafts();
      emit(
        LocalGalleryUploadSuccess(
          refreshed,
          '${draft.name} uploaded successfully',
        ),
      );
    } catch (e) {
      emit(LocalGalleryUploadError(currentDrafts, 'Upload failed: $e'));
    }
  }

  Future<void> deleteDraft(int id) async {
    try {
      await _repository.deleteDraft(id);
      await loadDrafts();
    } catch (e) {
      emit(LocalGalleryError(e.toString()));
    }
  }

  List<LocalGalleryDraft> get _currentDrafts {
    final s = state;
    if (s is LocalGalleryLoaded) return s.drafts;
    if (s is LocalGalleryUploadSuccess) return s.drafts;
    if (s is LocalGalleryUploadError) return s.drafts;
    return [];
  }
}
