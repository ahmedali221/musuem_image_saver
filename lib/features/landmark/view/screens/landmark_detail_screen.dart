import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:musuem_image_saver/core/di/service_locator.dart';
import 'package:musuem_image_saver/features/landmark/model/landmark_model.dart';
import 'package:musuem_image_saver/features/landmark/model/landmark_file_model.dart';
import 'package:musuem_image_saver/features/landmark/model/gallery_item_model.dart';
import 'package:musuem_image_saver/features/landmark/viewmodel/landmark_detail_cubit/landmark_detail_cubit.dart';
import 'package:musuem_image_saver/features/landmark/viewmodel/landmark_detail_cubit/landmark_detail_state.dart';
import 'package:musuem_image_saver/features/landmark/view/widgets/gallery_item_card.dart';
import 'package:musuem_image_saver/features/signature/viewmodel/signature_config_cubit/signature_config_cubit.dart';
import 'package:musuem_image_saver/features/signature/view/widgets/signature_actions_bar.dart';
import 'package:musuem_image_saver/features/local_gallery/viewmodel/local_gallery_cubit/local_gallery_cubit.dart';
import 'gallery_item_form_screens.dart';

// Landmark Detail Screen — shows info + gallery & files
class LandmarkDetailScreen extends StatelessWidget {
  final int projectId;
  final int landmarkId;

  const LandmarkDetailScreen({
    super.key,
    required this.projectId,
    required this.landmarkId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<LandmarkDetailCubit>()..loadLandmark(projectId, landmarkId),
        ),
        BlocProvider(create: (_) => sl<SignatureConfigCubit>()),
        BlocProvider(create: (_) => sl<LocalGalleryCubit>()),
      ],
      child: _LandmarkDetailBody(projectId: projectId, landmarkId: landmarkId),
    );
  }
}

class _LandmarkDetailBody extends StatelessWidget {
  final int projectId;
  final int landmarkId;

  const _LandmarkDetailBody({
    required this.projectId,
    required this.landmarkId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<LandmarkDetailCubit, LandmarkDetailState>(
      // Only rebuild layout when switching between major states
      buildWhen: (prev, curr) =>
          curr is LandmarkDetailLoading ||
          curr is LandmarkDetailLoaded ||
          curr is LandmarkDetailError ||
          curr is GalleryActionLoading ||
          curr is GalleryActionSuccess ||
          curr is GalleryActionError,

      // Snackbar feedback for gallery actions
      listenWhen: (prev, curr) =>
          curr is GalleryActionSuccess || curr is GalleryActionError,
      listener: (context, state) {
        if (state is GalleryActionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is GalleryActionError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
        }
      },

      builder: (context, state) {
        // Full-page loading (initial load)
        if (state is LandmarkDetailLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Full-page error (initial load failed)
        if (state is LandmarkDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 56,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<LandmarkDetailCubit>()
                          .loadLandmark(projectId, landmarkId),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Resolve the landmark from any state that carries data
        LandmarkModel? landmark;
        if (state is LandmarkDetailLoaded) landmark = state.landmark;
        if (state is GalleryActionLoading) landmark = state.landmark;
        if (state is GalleryActionSuccess) landmark = state.landmark;
        if (state is GalleryActionError) landmark = state.landmark;

        if (landmark != null) {
          final isActionLoading = state is GalleryActionLoading;
          return _LandmarkTabView(
            landmark: landmark,
            projectId: projectId,
            landmarkId: landmarkId,
            isActionLoading: isActionLoading,
          );
        }

        return Scaffold(appBar: AppBar());
      },
    );
  }
}

// ── Tab view (loaded state) ────────────────────────────────────────────────────

class _LandmarkTabView extends StatelessWidget {
  final LandmarkModel landmark;
  final int projectId;
  final int landmarkId;
  final bool isActionLoading;

  const _LandmarkTabView({
    required this.landmark,
    required this.projectId,
    required this.landmarkId,
    required this.isActionLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2, // Re-enabled Files tab
      child: Scaffold(
        // FAB for adding a new gallery item
        floatingActionButton: FloatingActionButton(
          onPressed: isActionLoading
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value: context.read<LandmarkDetailCubit>(),
                        ),
                        BlocProvider.value(
                          value: context.read<LocalGalleryCubit>(),
                        ),
                      ],
                      child: AddGalleryItemScreen(
                        projectId: projectId,
                        landmarkId: landmarkId,
                      ),
                    ),
                  ),
                ),
          tooltip: 'Add Gallery Item',
          child: isActionLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add),
        ),

        bottomNavigationBar: SignatureActionsBar(
          landmarkId: landmarkId,
          projectId: projectId,
        ),

        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  landmark.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: landmark.coverImageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.account_balance_rounded,
                          size: 64,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                indicatorColor: theme.colorScheme.primary,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.photo_library_outlined),
                    text: 'Gallery (${landmark.gallery?.length ?? 0})',
                  ),
                  Tab(
                    icon: const Icon(Icons.attach_file_rounded),
                    text: 'Files (${landmark.files?.length ?? 0})',
                  ),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              // ── Gallery Tab ──────────────────────────────────────────────
              (landmark.gallery == null || landmark.gallery!.isEmpty)
                  ? _buildEmptyTab(
                      theme,
                      Icons.photo_library_outlined,
                      'No gallery items yet',
                    )
                  : _buildGalleryGrid(context, landmark.gallery!, theme),

              // ── Files Tab ────────────────────────────────────────────────
              (landmark.files == null || landmark.files!.isEmpty)
                  ? _buildEmptyTab(
                      theme,
                      Icons.attach_file_rounded,
                      'No files uploaded',
                    )
                  : _buildFilesList(context, landmark.files!, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryGrid(
    BuildContext context,
    List<GalleryItemModel> gallery,
    ThemeData theme,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: gallery.length,
      itemBuilder: (ctx, index) {
        final item = gallery[index];
        return GalleryItemCard(
          item: item,
          onEdit: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<LandmarkDetailCubit>(),
                child: EditGalleryItemScreen(
                  projectId: projectId,
                  landmarkId: landmarkId,
                  item: item,
                ),
              ),
            ),
          ),
          onDelete: () => _confirmDelete(context, item),
        );
      },
    );
  }

  Widget _buildFilesList(
    BuildContext context,
    List<LandmarkFileModel> files,
    ThemeData theme,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: files.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final file = files[index];
        // Only allow download if not currently loading
        final canDownload = !isActionLoading;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.insert_drive_file_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.originalName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Size: ${file.fileSizeHuman} • Type: ${file.fileType.toUpperCase()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: canDownload
                      ? () {
                          context.read<LandmarkDetailCubit>().downloadFile(
                            projectId: projectId,
                            landmarkId: landmarkId,
                            fileId: file.id,
                            fileName: file.originalName,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.download_rounded),
                  tooltip: 'Download File',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, GalleryItemModel item) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Gallery Item'),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This cannot be undone.',
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
              context.read<LandmarkDetailCubit>().deleteGalleryItem(
                projectId: projectId,
                landmarkId: landmarkId,
                itemId: item.id,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTab(ThemeData theme, IconData icon, String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 56,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6E6E73),
            ),
          ),
        ],
      ),
    );
  }
}
