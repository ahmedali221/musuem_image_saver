import 'dart:io';

import 'package:dio/dio.dart';

import 'package:musuem_image_saver/core/network/api_endpoints.dart';
import 'package:musuem_image_saver/features/signature/model/signature_result_model.dart';

class SignatureRepository {
  final Dio _dio;

  SignatureRepository(this._dio);

  /// POST /api/signature-detector
  /// Sends the image file plus optional project_id / landmark_id.
  Future<SignatureResultModel> detectSignature({
    required File image,
    int? projectId,
    int? landmarkId,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split(Platform.pathSeparator).last,
      ),
      if (projectId != null) 'project_id': projectId,
      if (landmarkId != null) 'landmark_id': landmarkId,
    });

    final response = await _dio.post(
      ApiEndpoints.signatureDetector,
      data: formData,
    );

    final json =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return SignatureResultModel.fromJson(json);
  }

  /// POST /api/signature-configuration  (run)
  Future<String> runSignatureConfiguration({
    required int landmarkId,
    int? projectId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.signatureConfiguration,
      data: {
        'landmark_id': landmarkId,
        if (projectId != null) 'project_id': projectId,
      },
    );
    return (response.data as Map<String, dynamic>)['message'] as String? ??
        'Done';
  }

  /// PUT /api/signature-configuration  (update)
  Future<String> updateSignatureConfiguration({
    required int landmarkId,
    int? projectId,
    Map<String, dynamic>? params,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.signatureConfiguration,
      data: {
        'landmark_id': landmarkId,
        if (projectId != null) 'project_id': projectId,
        if (params != null) ...params,
      },
    );
    return (response.data as Map<String, dynamic>)['message'] as String? ??
        'Updated';
  }
}
