import 'package:musuem_image_saver/features/project/model/project_model.dart';

// All possible states for the projects list
abstract class ProjectState {}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<ProjectModel> projects;

  ProjectLoaded(this.projects);
}

class ProjectError extends ProjectState {
  final String message;

  ProjectError(this.message);
}
