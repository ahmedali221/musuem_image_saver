import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:musuem_image_saver/features/landmark/model/landmark_model.dart';

// Card shown in the LandmarksScreen list
class LandmarkCard extends StatelessWidget {
  final LandmarkModel landmark;
  final VoidCallback onTap;

  const LandmarkCard({super.key, required this.landmark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Status color — green for completed/active, orange for anything else
    final isGreen =
        landmark.status == 'active' || landmark.status == 'completed';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image at the top
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child: CachedNetworkImage(
                  imageUrl: landmark.coverImageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    child: Icon(
                      Icons.account_balance_rounded,
                      size: 48,
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          landmark.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (landmark.project?.name != null &&
                            landmark.project!.name.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            landmark.project!.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6E6E73),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isGreen
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      landmark.status,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isGreen
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
