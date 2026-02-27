import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';
import '../auth_repository.dart';

// Manages authentication logic: login, register, logout, auto-login
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  // Check if a token is stored so the user doesn't have to log in every time
  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      bool loggedIn = await _repository.isLoggedIn();
      if (loggedIn) {
        final user = await _repository.getUser();
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      // If the token is invalid or expired, go to login
      emit(Unauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _repository.login(email: email, password: password);
      final user = await _repository.getUser();
      emit(Authenticated(user));
    } on DioException catch (e) {
      emit(AuthError(_extractMessage(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(AuthLoading());
    try {
      await _repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final user = await _repository.getUser();
      emit(Authenticated(user));
    } on DioException catch (e) {
      emit(AuthError(_extractMessage(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _repository.logout();
    } catch (_) {
      // Even if the request fails, we still clear local state
    }
    emit(Unauthenticated());
  }

  // Pull the error message out of a Laravel API error response
  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('message')) {
      return data['message'] as String;
    }
    if (data is Map && data.containsKey('errors')) {
      final errors = data['errors'] as Map;
      return errors.values.first is List
          ? (errors.values.first as List).first.toString()
          : errors.values.first.toString();
    }
    return e.message ?? 'An unexpected error occurred.';
  }
}
