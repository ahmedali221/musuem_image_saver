import 'package:musuem_image_saver/features/monument_profile/model/monument_profile_model.dart';

// All possible states for the monument profiles list
abstract class MonumentProfileState {}

class MonumentProfileInitial extends MonumentProfileState {}

class MonumentProfileLoading extends MonumentProfileState {}

class MonumentProfileLoaded extends MonumentProfileState {
  final List<MonumentProfileModel> profiles;

  MonumentProfileLoaded(this.profiles);
}

class MonumentProfileError extends MonumentProfileState {
  final String message;

  MonumentProfileError(this.message);
}
