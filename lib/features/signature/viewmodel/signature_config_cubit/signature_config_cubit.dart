import 'package:flutter_bloc/flutter_bloc.dart';

import 'signature_config_state.dart';
import '../signature_repository.dart';

class SignatureConfigCubit extends Cubit<SignatureConfigState> {
  final SignatureRepository _repository;

  SignatureConfigCubit(this._repository) : super(SignatureConfigInitial());

  /// POST /api/signature-configuration
  Future<void> runSignature({required int landmarkId, int? projectId}) async {
    emit(SignatureConfigLoading());
    try {
      final message = await _repository.runSignatureConfiguration(
        landmarkId: landmarkId,
        projectId: projectId,
      );
      emit(SignatureConfigSuccess(message));
    } catch (e) {
      emit(SignatureConfigError(e.toString()));
    }
  }

  /// PUT /api/signature-configuration
  Future<void> updateConfiguration({
    required int landmarkId,
    int? projectId,
    Map<String, dynamic>? params,
  }) async {
    emit(SignatureConfigLoading());
    try {
      final message = await _repository.updateSignatureConfiguration(
        landmarkId: landmarkId,
        projectId: projectId,
        params: params,
      );
      emit(SignatureConfigSuccess(message));
    } catch (e) {
      emit(SignatureConfigError(e.toString()));
    }
  }
}
