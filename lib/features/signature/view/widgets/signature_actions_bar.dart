import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:musuem_image_saver/features/signature/viewmodel/signature_config_cubit/signature_config_cubit.dart';
import 'package:musuem_image_saver/features/signature/viewmodel/signature_config_cubit/signature_config_state.dart';

/// Sticky bottom bar shown on the landmark detail page.
/// Contains "Run Signature" (POST) and "Update Configuration" (PUT) buttons.
class SignatureActionsBar extends StatelessWidget {
  final int landmarkId;
  final int? projectId;

  const SignatureActionsBar({
    super.key,
    required this.landmarkId,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignatureConfigCubit, SignatureConfigState>(
      listener: (context, state) {
        if (state is SignatureConfigSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade700,
              ),
            );
        } else if (state is SignatureConfigError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      builder: (context, state) {
        final isLoading = state is SignatureConfigLoading;

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _RunSignatureButton(
                    isLoading: isLoading,
                    landmarkId: landmarkId,
                    projectId: projectId,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _UpdateConfigButton(
                    isLoading: isLoading,
                    landmarkId: landmarkId,
                    projectId: projectId,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _RunSignatureButton extends StatelessWidget {
  final bool isLoading;
  final int landmarkId;
  final int? projectId;

  const _RunSignatureButton({
    required this.isLoading,
    required this.landmarkId,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading
          ? null
          : () => context.read<SignatureConfigCubit>().runSignature(
              landmarkId: landmarkId,
              projectId: projectId,
            ),
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.play_arrow_rounded),
      label: const Text('Run Signature'),
    );
  }
}

class _UpdateConfigButton extends StatelessWidget {
  final bool isLoading;
  final int landmarkId;
  final int? projectId;

  const _UpdateConfigButton({
    required this.isLoading,
    required this.landmarkId,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading
          ? null
          : () => context.read<SignatureConfigCubit>().updateConfiguration(
              landmarkId: landmarkId,
              projectId: projectId,
            ),
      icon: const Icon(Icons.tune_rounded),
      label: const Text('Update Config'),
    );
  }
}
