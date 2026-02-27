import 'package:musuem_image_saver/features/landmark/model/landmark_model.dart';

abstract class LandmarkState {}

class LandmarkInitial extends LandmarkState {}

class LandmarkLoading extends LandmarkState {}

class LandmarkLoaded extends LandmarkState {
  final List<LandmarkModel> landmarks;
  LandmarkLoaded(this.landmarks);
}

class LandmarkError extends LandmarkState {
  final String message;
  LandmarkError(this.message);
}
