import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'signature_state.dart';
import '../signature_repository.dart';

class SignatureCubit extends Cubit<SignatureState> {
  final SignatureRepository _repository;
  final ImagePicker _picker = ImagePicker();

  SignatureCubit(this._repository) : super(SignatureInitial());

  Future<void> pickImage() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;
    emit(SignatureImagePicked(xFile.path));
  }

  Future<void> pickImageFromCamera() async {
    final xFile = await _picker.pickImage(source: ImageSource.camera);
    if (xFile == null) return;
    emit(SignatureImagePicked(xFile.path));
  }

  Future<void> detectSignature({
    required String imagePath,
    int? projectId,
    int? landmarkId,
  }) async {
    emit(SignatureLoading(imagePath));
    try {
      final result = await _repository.detectSignature(
        image: File(imagePath),
        projectId: projectId,
        landmarkId: landmarkId,
      );
      emit(SignatureSuccess(imagePath: imagePath, result: result));
    } catch (e) {
      emit(SignatureError(imagePath: imagePath, message: e.toString()));
    }
  }
}
