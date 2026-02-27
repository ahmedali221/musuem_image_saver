import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:musuem_image_saver/core/di/service_locator.dart';
import 'package:musuem_image_saver/features/project/model/project_model.dart';
import 'package:musuem_image_saver/features/landmark/viewmodel/landmark_cubit/landmark_cubit.dart';
import 'package:musuem_image_saver/features/landmark/viewmodel/landmark_cubit/landmark_state.dart';
import 'package:musuem_image_saver/features/landmark/view/widgets/landmark_card.dart';

class ProjectDetailScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create a fresh LandmarkCubit explicitly for this project
      create: (_) => sl<LandmarkCubit>()..loadLandmarks(project.id),
      child: _ProjectDetailBody(project: project),
    );
  }
}

class _ProjectDetailBody extends StatelessWidget {
  final ProjectModel project;

  const _ProjectDetailBody({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            forceElevated: innerBoxIsScrolled,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: project.coverImageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.collections,
                        size: 64,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<LandmarkCubit>().loadLandmarks(project.id);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Project Title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  project.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Project Description
              if (project.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Text(
                    project.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4A4A4F),
                      height: 1.5,
                    ),
                  ),
                ),

              // Header for Landmarks
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Landmarks',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const Divider(height: 1),

              // Landmark List Builder
              BlocBuilder<LandmarkCubit, LandmarkState>(
                builder: (context, state) {
                  if (state is LandmarkLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is LandmarkError) {
                    return Padding(
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
                                .read<LandmarkCubit>()
                                .loadLandmarks(project.id),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is LandmarkLoaded) {
                    if (state.landmarks.isEmpty) {
                      return _buildEmptyState(theme);
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: state.landmarks.length,
                      itemBuilder: (context, index) {
                        final landmark = state.landmarks[index];
                        return LandmarkCard(
                          landmark: landmark,
                          onTap: () {
                            context.push(
                              '/projects/${project.id}/landmarks/${landmark.id}',
                            );
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
      // Action to add landmark wouldn't be here since API doesn't mention landmark creation yet, just listing.
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.secondary.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.account_balance_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No Landmarks Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This project doesn\'t have any landmarks associated with it.',
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
