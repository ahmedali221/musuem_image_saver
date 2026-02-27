import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:musuem_image_saver/core/di/service_locator.dart';
import 'package:musuem_image_saver/features/local_gallery/model/local_gallery_draft.dart';
import 'package:musuem_image_saver/features/local_gallery/viewmodel/local_gallery_cubit/local_gallery_cubit.dart';
import 'package:musuem_image_saver/features/local_gallery/viewmodel/local_gallery_cubit/local_gallery_state.dart';

class LocalGalleryScreen extends StatelessWidget {
  const LocalGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalGalleryCubit>()..loadDrafts(),
      child: const _LocalGalleryBody(),
    );
  }
}

class _LocalGalleryBody extends StatelessWidget {
  const _LocalGalleryBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Drafts'), centerTitle: true),
      body: BlocConsumer<LocalGalleryCubit, LocalGalleryState>(
        listener: (context, state) {
          if (state is LocalGalleryUploadSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green.shade700,
                ),
              );
          } else if (state is LocalGalleryUploadError) {
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
          if (state is LocalGalleryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LocalGalleryError) {
            return _ErrorView(message: state.message);
          }

          // Unpack drafts + uploadingId from any state that carries them
          List<LocalGalleryDraft>? drafts;
          int? uploadingId;

          if (state is LocalGalleryLoaded) {
            drafts = state.drafts;
            uploadingId = state.uploadingId;
          } else if (state is LocalGalleryUploadSuccess) {
            drafts = state.drafts;
          } else if (state is LocalGalleryUploadError) {
            drafts = state.drafts;
          }

          if (drafts == null) return const SizedBox.shrink();
          if (drafts.isEmpty) return const _EmptyView();

          return _DraftsList(drafts: drafts, uploadingId: uploadingId);
        },
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _DraftsList extends StatelessWidget {
  final List<LocalGalleryDraft> drafts;
  final int? uploadingId;

  const _DraftsList({required this.drafts, this.uploadingId});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: drafts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _DraftCard(
        draft: drafts[index],
        isUploading: uploadingId == drafts[index].id,
        anyUploading: uploadingId != null,
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final LocalGalleryDraft draft;
  final bool isUploading;
  final bool anyUploading;

  const _DraftCard({
    required this.draft,
    required this.isUploading,
    required this.anyUploading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstImage = draft.imagePaths.isNotEmpty
        ? draft.imagePaths.first
        : null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DraftThumbnail(imagePath: firstImage),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _DraftMeta(draft: draft),
          ),
          _DraftActions(
            draft: draft,
            isUploading: isUploading,
            anyUploading: anyUploading,
          ),
        ],
      ),
    );
  }
}

class _DraftThumbnail extends StatelessWidget {
  final String? imagePath;
  const _DraftThumbnail({this.imagePath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (imagePath == null) {
      return Container(
        height: 140,
        color: theme.colorScheme.primary.withValues(alpha: 0.07),
        child: Center(
          child: Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: theme.colorScheme.primary.withValues(alpha: 0.35),
          ),
        ),
      );
    }
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Image.file(File(imagePath!), fit: BoxFit.cover),
    );
  }
}

class _DraftMeta extends StatelessWidget {
  final LocalGalleryDraft draft;
  const _DraftMeta({required this.draft});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          draft.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        _InfoChipRow(draft: draft),
        const SizedBox(height: 8),
        _ProjectLandmarkBadge(draft: draft),
        const SizedBox(height: 4),
        Text(
          'Saved ${_formatDate(draft.createdAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF9E9EA7),
          ),
        ),
      ],
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _InfoChipRow extends StatelessWidget {
  final LocalGalleryDraft draft;
  const _InfoChipRow({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _Chip(label: draft.partType),
        _Chip(label: draft.signatureType),
        if (draft.imagePaths.isNotEmpty)
          _Chip(
            label:
                '${draft.imagePaths.length} image${draft.imagePaths.length == 1 ? '' : 's'}',
            icon: Icons.photo,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _Chip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectLandmarkBadge extends StatelessWidget {
  final LocalGalleryDraft draft;
  const _ProjectLandmarkBadge({required this.draft});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Icon(Icons.folder_outlined, size: 14, color: Color(0xFF9E9EA7)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            draft.projectName.isNotEmpty
                ? draft.projectName
                : 'Project #${draft.projectId}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6E6E73),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.place_outlined, size: 14, color: Color(0xFF9E9EA7)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            draft.landmarkName.isNotEmpty
                ? draft.landmarkName
                : 'Landmark #${draft.landmarkId}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6E6E73),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DraftActions extends StatelessWidget {
  final LocalGalleryDraft draft;
  final bool isUploading;
  final bool anyUploading;

  const _DraftActions({
    required this.draft,
    required this.isUploading,
    required this.anyUploading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        children: [
          // Upload button
          Expanded(
            child: FilledButton.icon(
              onPressed: (!anyUploading)
                  ? () => context.read<LocalGalleryCubit>().uploadDraft(draft)
                  : null,
              icon: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined, size: 18),
              label: Text(isUploading ? 'Uploading…' : 'Upload'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Delete button
          OutlinedButton(
            onPressed: anyUploading ? null : () => _confirmDelete(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(Icons.delete_outline_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final cubit = context.read<LocalGalleryCubit>();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Draft'),
        content: Text(
          'Remove "${draft.name}" from local storage? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (draft.id != null) cubit.deleteDraft(draft.id!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 72,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Local Drafts',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Gallery items you add will appear here, ready to upload.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6E6E73),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<LocalGalleryCubit>().loadDrafts(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
