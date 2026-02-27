// Tracks whether each password field is showing or hiding its text
class AuthFormState {
  final bool passwordVisible;
  final bool confirmVisible;

  const AuthFormState({
    this.passwordVisible = false,
    this.confirmVisible = false,
  });

  // Returns a new state with only the changed field updated
  AuthFormState copyWith({bool? passwordVisible, bool? confirmVisible}) {
    return AuthFormState(
      passwordVisible: passwordVisible ?? this.passwordVisible,
      confirmVisible: confirmVisible ?? this.confirmVisible,
    );
  }
}
