import 'package:musuem_image_saver/features/auth/model/user_model.dart';

// All possible states for authentication
abstract class AuthState {}

// App just started, no check done yet
class AuthInitial extends AuthState {}

// Waiting for a network response
class AuthLoading extends AuthState {}

// User is logged in — holds the user data
class Authenticated extends AuthState {
  final UserModel user;

  Authenticated(this.user);
}

// User is not logged in
class Unauthenticated extends AuthState {}

// Something went wrong — holds the error message
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
