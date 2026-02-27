import 'package:musuem_image_saver/features/signature/model/signature_result_model.dart';

abstract class SignatureState {}

class SignatureInitial extends SignatureState {}

class SignatureImagePicked extends SignatureState {
  final String imagePath;
  SignatureImagePicked(this.imagePath);
}

class SignatureLoading extends SignatureState {
  final String imagePath;
  SignatureLoading(this.imagePath);
}

class SignatureSuccess extends SignatureState {
  final String imagePath;
  final SignatureResultModel result;
  SignatureSuccess({required this.imagePath, required this.result});
}

class SignatureError extends SignatureState {
  final String imagePath;
  final String message;
  SignatureError({required this.imagePath, required this.message});
}
