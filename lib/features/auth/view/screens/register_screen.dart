import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:musuem_image_saver/features/auth/view/widgets/custom_input_field.dart';
import 'package:musuem_image_saver/features/auth/viewmodel/auth_cubit/auth_cubit.dart';
import 'package:musuem_image_saver/features/auth/viewmodel/auth_cubit/auth_state.dart';
import 'package:musuem_image_saver/features/auth/viewmodel/auth_form_cubit/auth_form_cubit.dart';
import 'package:musuem_image_saver/features/auth/viewmodel/auth_form_cubit/auth_form_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        // Show error snack bar if the request fails
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon at the top
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    size: 44,
                    color: theme.colorScheme.secondary,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Create Account',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Join Museum Saver to get started',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6E6E73),
                  ),
                ),

                const SizedBox(height: 36),

                // Form fields — rebuilt when visibility toggles
                BlocBuilder<AuthFormCubit, AuthFormState>(
                  builder: (context, formState) {
                    final formCubit = context.read<AuthFormCubit>();

                    return Form(
                      key: formCubit.registerFormKey,
                      child: Column(
                        children: [
                          // Full name
                          CustomInputField(
                            controller: formCubit.nameController,
                            label: 'Full Name',
                            prefixIcon: Icons.person_outline,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Email
                          CustomInputField(
                            controller: formCubit.emailController,
                            label: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Password with visibility toggle
                          CustomInputField(
                            controller: formCubit.passwordController,
                            label: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: !formState.passwordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                formState.passwordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: formCubit.togglePasswordVisibility,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Confirm password — must match the password above
                          CustomInputField(
                            controller: formCubit.confirmController,
                            label: 'Confirm Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: !formState.confirmVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                formState.confirmVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: formCubit.toggleConfirmVisibility,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != formCubit.passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // Create Account button
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, authState) {
                              bool isLoading = authState is AuthLoading;

                              return SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          // Validate the form first
                                          if (!formCubit
                                              .registerFormKey
                                              .currentState!
                                              .validate())
                                            return;

                                          // Call register directly in the button
                                          context.read<AuthCubit>().register(
                                            name: formCubit.nameController.text
                                                .trim(),
                                            email: formCubit
                                                .emailController
                                                .text
                                                .trim(),
                                            password: formCubit
                                                .passwordController
                                                .text,
                                            passwordConfirmation: formCubit
                                                .confirmController
                                                .text,
                                          );
                                        },
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Create Account'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Link back to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6E6E73),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Go back to the login screen
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Sign In',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
