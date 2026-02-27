import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:musuem_image_saver/features/auth/view/widgets/custom_input_field.dart';
import 'package:musuem_image_saver/features/auth/viewmodel/auth_cubit/auth_cubit.dart';
import 'package:musuem_image_saver/features/auth/viewmodel/auth_cubit/auth_state.dart';
import 'package:musuem_image_saver/features/auth/viewmodel/auth_form_cubit/auth_form_cubit.dart';
import 'package:musuem_image_saver/features/auth/viewmodel/auth_form_cubit/auth_form_state.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        // Show a snack bar if something goes wrong
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // App icon at the top
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    size: 44,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Welcome Back',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to continue to Museum Saver',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6E6E73),
                  ),
                ),

                const SizedBox(height: 40),

                // Form fields — rebuilt when visibility toggles
                BlocBuilder<AuthFormCubit, AuthFormState>(
                  builder: (context, formState) {
                    final formCubit = context.read<AuthFormCubit>();

                    return Form(
                      key: formCubit.loginFormKey,
                      child: Column(
                        children: [
                          // Email field
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

                          // Password field with show/hide toggle
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
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // Sign In button
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
                                              .loginFormKey
                                              .currentState!
                                              .validate())
                                            return;

                                          // Call login directly in the button
                                          context.read<AuthCubit>().login(
                                            email: formCubit
                                                .emailController
                                                .text
                                                .trim(),
                                            password: formCubit
                                                .passwordController
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
                                      : const Text('Sign In'),
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

                // Link to the register screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6E6E73),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                  value: context.read<AuthCubit>(),
                                ),
                                BlocProvider.value(
                                  value: context.read<AuthFormCubit>(),
                                ),
                              ],
                              child: const RegisterScreen(),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
