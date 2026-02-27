import 'package:dio/dio.dart';

import 'package:musuem_image_saver/core/network/api_endpoints.dart';
import 'package:musuem_image_saver/features/project/model/project_model.dart';

// Handles all network requests related to projects
class ProjectRepository {
  final Dio _dio;

  ProjectRepository(this._dio);

  // GET /api/projects — returns the full list of projects
  // The server wraps the list like: { "success": true, "data": [...] }
  Future<List<ProjectModel>> getAllProjects() async {
    final response = await _dio.get(ApiEndpoints.projects);

    // Unwrap the "data" key — the real list lives inside the envelope
    final List<dynamic> data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;

    return data
        .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // GET /api/projects/{id} — returns a single project
  // Assumes the same { "success": true, "data": {...} } envelope
  Future<ProjectModel> getProjectById(int id) async {
    final response = await _dio.get(ApiEndpoints.projectById(id));

    final json =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;

    return ProjectModel.fromJson(json);
  }
}
