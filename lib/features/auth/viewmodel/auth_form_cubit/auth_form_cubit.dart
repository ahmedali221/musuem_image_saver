import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_form_state.dart';

// Handles form UI state: controllers, form keys, and password visibility.
// We keep controllers here so screens don't need to be StatefulWidgets.
class AuthFormCubit extends Cubit<AuthFormState> {
  // Login screen controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Register screen extra controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  // Form keys — one per screen
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  AuthFormCubit() : super(const AuthFormState());

  // Show or hide the password field text
  void togglePasswordVisibility() {
    emit(state.copyWith(passwordVisible: !state.passwordVisible));
  }

  // Show or hide the confirm password field text
  void toggleConfirmVisibility() {
    emit(state.copyWith(confirmVisible: !state.confirmVisible));
  }

  // Clear all fields — useful after logout
  void clearFields() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmController.clear();
  }

  @override
  Future<void> close() {
    // Clean up controllers when the cubit is removed from the widget tree
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmController.dispose();
    return super.close();
  }
}
