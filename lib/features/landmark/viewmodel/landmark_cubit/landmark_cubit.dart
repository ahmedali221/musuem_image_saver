import 'package:flutter_bloc/flutter_bloc.dart';

import 'landmark_state.dart';
import '../landmark_repository.dart';

// Loads all landmarks from the API
class LandmarkCubit extends Cubit<LandmarkState> {
  final LandmarkRepository _repository;

  LandmarkCubit(this._repository) : super(LandmarkInitial());

  Future<void> loadLandmarks(int projectId) async {
    emit(LandmarkLoading());
    try {
      final landmarks = await _repository.getLandmarksByProject(projectId);
      emit(LandmarkLoaded(landmarks));
    } catch (e) {
      emit(LandmarkError('Failed to load landmarks: $e'));
    }
  }
}
