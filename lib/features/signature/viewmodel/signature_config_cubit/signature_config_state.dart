abstract class SignatureConfigState {}

class SignatureConfigInitial extends SignatureConfigState {}

class SignatureConfigLoading extends SignatureConfigState {}

class SignatureConfigSuccess extends SignatureConfigState {
  final String message;
  SignatureConfigSuccess(this.message);
}

class SignatureConfigError extends SignatureConfigState {
  final String message;
  SignatureConfigError(this.message);
}
