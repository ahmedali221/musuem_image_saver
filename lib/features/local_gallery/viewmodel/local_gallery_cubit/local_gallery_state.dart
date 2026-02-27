import 'package:musuem_image_saver/features/local_gallery/model/local_gallery_draft.dart';

abstract class LocalGalleryState {}

class LocalGalleryInitial extends LocalGalleryState {}

class LocalGalleryLoading extends LocalGalleryState {}

class LocalGalleryLoaded extends LocalGalleryState {
  final List<LocalGalleryDraft> drafts;
  final int? uploadingId; // draft currently being uploaded (null = none)
  LocalGalleryLoaded(this.drafts, {this.uploadingId});
}

class LocalGalleryError extends LocalGalleryState {
  final String message;
  LocalGalleryError(this.message);
}

class LocalGalleryUploadSuccess extends LocalGalleryState {
  final List<LocalGalleryDraft> drafts;
  final String message;
  LocalGalleryUploadSuccess(this.drafts, this.message);
}

class LocalGalleryUploadError extends LocalGalleryState {
  final List<LocalGalleryDraft> drafts;
  final String message;
  LocalGalleryUploadError(this.drafts, this.message);
}
