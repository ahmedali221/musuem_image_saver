import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../model/monument_profile_model.dart';
import '../../viewmodel/monument_profile_cubit/monument_profile_cubit.dart';

class ProfileDetailScreen extends StatelessWidget {
  final MonumentProfileModel profile;

  const ProfileDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero Image AppBar ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                profile.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 12)],
                ),
              ),
              background: profile.imagePaths.isNotEmpty
                  ? Image.file(
                      File(profile.imagePaths.first),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                            theme.colorScheme.secondary.withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        size: 80,
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Added ${DateFormat.yMMMd().format(profile.createdAt)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Part Type & Signature Type badges
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildBadge(
                        theme,
                        Icons.category_outlined,
                        'Part Type',
                        profile.partType.label,
                        theme.colorScheme.primary,
                      ),
                      _buildBadge(
                        theme,
                        Icons.history_edu_outlined,
                        'Signature',
                        profile.signatureType.label,
                        theme.colorScheme.secondary,
                      ),
                      if (profile.partType == PartType.targetMural &&
                          profile.muralWidth != null &&
                          profile.muralHeight != null)
                        _buildBadge(
                          theme,
                          Icons.straighten_outlined,
                          'Dimensions',
                          '${profile.muralWidth} × ${profile.muralHeight} cm',
                          Colors.orange,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description section
                  _buildSectionTitle(
                    theme,
                    Icons.description_outlined,
                    'Description',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    profile.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF3A3A3C),
                      height: 1.6,
                    ),
                  ),

                  if (profile.notes.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSectionTitle(theme, Icons.note_alt_outlined, 'Notes'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.06,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ),
                      child: Text(
                        profile.notes,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6E6E73),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  // Images gallery
                  if (profile.imagePaths.length > 1) ...[
                    const SizedBox(height: 28),
                    _buildSectionTitle(
                      theme,
                      Icons.photo_library_outlined,
                      'Gallery',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: profile.imagePaths.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 240,
                            margin: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(profile.imagePaths[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Monument'),
          content: Text(
            'Are you sure you want to delete "${profile.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<MonumentProfileCubit>().deleteProfile(profile.id);
                Navigator.pop(ctx); // close dialog
                Navigator.pop(context); // back to home
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
