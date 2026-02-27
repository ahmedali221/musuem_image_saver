import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:musuem_image_saver/core/di/service_locator.dart';
import 'package:musuem_image_saver/features/signature/viewmodel/signature_cubit/signature_cubit.dart';
import 'package:musuem_image_saver/features/signature/viewmodel/signature_cubit/signature_state.dart';
import 'package:musuem_image_saver/features/signature/view/widgets/signature_image_preview.dart';
import 'package:musuem_image_saver/features/signature/view/widgets/signature_result_card.dart';

class SignatureScreen extends StatelessWidget {
  final int? projectId;
  final int? landmarkId;

  const SignatureScreen({super.key, this.projectId, this.landmarkId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SignatureCubit>(),
      child: _SignatureBody(projectId: projectId, landmarkId: landmarkId),
    );
  }
}

class _SignatureBody extends StatelessWidget {
  final int? projectId;
  final int? landmarkId;

  const _SignatureBody({this.projectId, this.landmarkId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature Detection'),
        centerTitle: true,
      ),
      body: BlocBuilder<SignatureCubit, SignatureState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SignatureHeaderText(),
                const SizedBox(height: 20),
                SignatureImagePreview(
                  imagePath: state is SignatureInitial
                      ? null
                      : _pathFrom(state),
                ),
                const SizedBox(height: 20),
                _PickImageButton(),
                const SizedBox(height: 12),
                _DetectButton(projectId: projectId, landmarkId: landmarkId),
                const SizedBox(height: 28),
                if (state is SignatureLoading) const _LoadingIndicator(),
                if (state is SignatureSuccess)
                  SignatureResultCard(result: state.result),
                if (state is SignatureError) _ErrorCard(message: state.message),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _pathFrom(SignatureState state) {
    if (state is SignatureImagePicked) return state.imagePath;
    if (state is SignatureLoading) return state.imagePath;
    if (state is SignatureSuccess) return state.imagePath;
    if (state is SignatureError) return state.imagePath;
    return null;
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _SignatureHeaderText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detect a Signature',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pick an image from your gallery and send it for analysis.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6E6E73),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _PickImageButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showSourcePicker(context),
      icon: const Icon(Icons.photo_library_outlined),
      label: const Text('Pick Image'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showSourcePicker(BuildContext context) {
    final cubit = context.read<SignatureCubit>();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ImageSourceSheet(cubit: cubit),
    );
  }
}

class _DetectButton extends StatelessWidget {
  final int? projectId;
  final int? landmarkId;

  const _DetectButton({this.projectId, this.landmarkId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignatureCubit, SignatureState>(
      builder: (context, state) {
        final hasImage = state is! SignatureInitial;
        final isLoading = state is SignatureLoading;

        return FilledButton.icon(
          onPressed: (hasImage && !isLoading)
              ? () {
                  final path = _pathFromState(state);
                  if (path != null) {
                    context.read<SignatureCubit>().detectSignature(
                      imagePath: path,
                      projectId: projectId,
                      landmarkId: landmarkId,
                    );
                  }
                }
              : null,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.search_rounded),
          label: const Text('Detect Signature'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }

  String? _pathFromState(SignatureState state) {
    if (state is SignatureImagePicked) return state.imagePath;
    if (state is SignatureSuccess) return state.imagePath;
    if (state is SignatureError) return state.imagePath;
    return null;
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.error.withValues(alpha: 0.08),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image source picker sheet ─────────────────────────────────────────────────

class _ImageSourceSheet extends StatelessWidget {
  final SignatureCubit cubit;

  const _ImageSourceSheet({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Select Image Source',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const Divider(height: 1),
            _SourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              onTap: () {
                Navigator.of(context).pop();
                cubit.pickImage();
              },
            ),
            _SourceTile(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              onTap: () {
                Navigator.of(context).pop();
                cubit.pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
