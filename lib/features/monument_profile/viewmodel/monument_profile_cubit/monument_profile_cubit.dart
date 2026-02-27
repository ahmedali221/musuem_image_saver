import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musuem_image_saver/features/monument_profile/model/monument_profile_model.dart';

import 'monument_profile_state.dart';
import '../monument_profile_repository.dart';

// Manages loading, adding, and deleting monument profiles for a project
class MonumentProfileCubit extends Cubit<MonumentProfileState> {
  final MonumentProfileRepository _repository;

  // Each cubit instance is scoped to one project
  final String projectId;

  MonumentProfileCubit(this._repository, {required this.projectId})
    : super(MonumentProfileInitial());

  // Load all profiles that belong to this project
  Future<void> loadProfiles() async {
    emit(MonumentProfileLoading());
    try {
      final profiles = await _repository.getProfilesByProject(projectId);
      emit(MonumentProfileLoaded(profiles));
    } catch (e) {
      emit(MonumentProfileError('Failed to load profiles: $e'));
    }
  }

  // Save a new profile under this project
  Future<void> addProfile({
    required String name,
    required String description,
    required String notes,
    required PartType partType,
    required SignatureType signatureType,
    double? muralWidth,
    double? muralHeight,
    required List<String> tempImagePaths,
  }) async {
    try {
      await _repository.addProfile(
        projectId: projectId,
        name: name,
        description: description,
        notes: notes,
        partType: partType,
        signatureType: signatureType,
        muralWidth: muralWidth,
        muralHeight: muralHeight,
        tempImagePaths: tempImagePaths,
      );
      await loadProfiles();
    } catch (e) {
      emit(MonumentProfileError('Failed to add profile: $e'));
    }
  }

  // Delete a profile by id and refresh the list
  Future<void> deleteProfile(String id) async {
    try {
      await _repository.deleteProfile(id);
      await loadProfiles();
    } catch (e) {
      emit(MonumentProfileError('Failed to delete profile: $e'));
    }
  }
}
