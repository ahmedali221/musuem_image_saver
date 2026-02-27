import 'package:flutter_bloc/flutter_bloc.dart';

import 'project_state.dart';
import '../project_repository.dart';

// Manages loading projects from the API
class ProjectCubit extends Cubit<ProjectState> {
  final ProjectRepository _repository;

  ProjectCubit(this._repository) : super(ProjectInitial());

  // Load all projects from the API
  Future<void> loadProjects() async {
    emit(ProjectLoading());
    try {
      final projects = await _repository.getAllProjects();
      emit(ProjectLoaded(projects));
    } catch (e) {
      emit(ProjectError('Failed to load projects: $e'));
    }
  }
}
