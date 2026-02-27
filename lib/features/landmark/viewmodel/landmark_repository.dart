import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:musuem_image_saver/core/network/api_endpoints.dart';
import 'package:musuem_image_saver/features/landmark/model/landmark_model.dart';
import 'package:musuem_image_saver/features/landmark/model/gallery_item_model.dart';

class LandmarkRepository {
  final Dio _dio;
  LandmarkRepository(this._dio);

  // GET /api/projects/{projectId}/landmarks
  Future<List<LandmarkModel>> getLandmarksByProject(int projectId) async {
    final response = await _dio.get(ApiEndpoints.projectLandmarks(projectId));
    final List<dynamic> data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((e) => LandmarkModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /api/projects/{projectId}/landmarks/{landmarkId}
  Future<LandmarkModel> getLandmarkById(int projectId, int landmarkId) async {
    final response = await _dio.get(
      ApiEndpoints.projectLandmarkById(projectId, landmarkId),
    );
    final json =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return LandmarkModel.fromJson(json);
  }

  // POST /api/projects/{projectId}/landmarks/{landmarkId}/gallery
  Future<GalleryItemModel> createGalleryItem(
    int projectId,
    int landmarkId,
    FormData formData,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.landmarkGalleryCreate(projectId, landmarkId),
      data: formData,
    );
    final json =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return GalleryItemModel.fromJson(json);
  }

  // PATCH /api/projects/{projectId}/landmarks/{landmarkId}/gallery/{itemId}
  Future<GalleryItemModel> updateGalleryItem(
    int projectId,
    int landmarkId,
    int itemId,
    FormData formData,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.landmarkGalleryUpdate(projectId, landmarkId, itemId),
      data: formData..fields.add(const MapEntry('_method', 'PATCH')),
    );
    final json =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return GalleryItemModel.fromJson(json);
  }

  // DELETE /api/projects/{projectId}/landmarks/{landmarkId}/gallery/{itemId}
  Future<void> deleteGalleryItem(
    int projectId,
    int landmarkId,
    int itemId,
  ) async {
    await _dio.delete(
      ApiEndpoints.landmarkGalleryDelete(projectId, landmarkId, itemId),
    );
  }

  // DOWNLOAD /api/projects/{projectId}/landmarks/{landmarkId}/files/download
  Future<String> downloadFile(
    int projectId,
    int landmarkId,
    int fileId,
    String fileName,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$fileName';

    await _dio.download(
      ApiEndpoints.landmarkFilesDownload(projectId, landmarkId),
      savePath,
      queryParameters: {'file_id': fileId},
    );
    return savePath;
  }
}
