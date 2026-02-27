import 'package:musuem_image_saver/features/landmark/model/landmark_model.dart';

abstract class LandmarkDetailState {}

class LandmarkDetailInitial extends LandmarkDetailState {}

class LandmarkDetailLoading extends LandmarkDetailState {}

class LandmarkDetailLoaded extends LandmarkDetailState {
  final LandmarkModel landmark;
  LandmarkDetailLoaded(this.landmark);
}

class LandmarkDetailError extends LandmarkDetailState {
  final String message;
  LandmarkDetailError(this.message);
}

// ── Gallery action sub-states ─────────────────────────────────────────────────

/// In-flight: spinner on the button; [landmark] keeps the screen populated.
class GalleryActionLoading extends LandmarkDetailState {
  final LandmarkModel landmark;
  GalleryActionLoading(this.landmark);
}

/// Success: triggers a snackbar and shows the updated data.
class GalleryActionSuccess extends LandmarkDetailState {
  final LandmarkModel landmark;
  final String message;
  GalleryActionSuccess(this.landmark, this.message);
}

/// Failure: shows an error without blanking the existing data.
class GalleryActionError extends LandmarkDetailState {
  final LandmarkModel landmark;
  final String message;
  GalleryActionError(this.landmark, this.message);
}
