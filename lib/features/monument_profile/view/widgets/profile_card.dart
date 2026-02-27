import 'dart:io';

import 'package:flutter/material.dart';

import '../../model/monument_profile_model.dart';

class ProfileCard extends StatelessWidget {
  final MonumentProfileModel profile;
  final VoidCallback onTap;

  const ProfileCard({super.key, required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = profile.imagePaths.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.cardTheme.color ?? const Color(0xFFF5F5FA),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // ── Thumbnail ──
              SizedBox(
                width: 120,
                height: 130,
                child: hasImage
                    ? Image.file(
                        File(profile.imagePaths.first),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        child: Icon(
                          Icons.account_balance,
                          size: 48,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
              ),

              // ── Text content ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Part type & Signature chips
                      Row(
                        children: [
                          _buildChip(
                            context,
                            profile.partType.label,
                            theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          _buildChip(
                            context,
                            profile.signatureType.label,
                            theme.colorScheme.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6E6E73),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.imagePaths.length} image${profile.imagePaths.length == 1 ? '' : 's'}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Arrow ──
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
