import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:musuem_image_saver/features/auth/viewmodel/auth_cubit/auth_cubit.dart';
import 'app_drawer_item.dart';

// Full side-drawer used in the app's main screens.
// Drop it directly into Scaffold(drawer: ...) — no shell wrapping needed.
class AppDrawer extends StatelessWidget {
  /// Path of the currently active route, used to highlight the selected item.
  final String currentPath;

  const AppDrawer({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.72),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Museum Image Saver',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nile Tech',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Navigation ───────────────────────────────────────────────────
          AppDrawerItem(
            icon: Icons.folder_rounded,
            label: 'Projects',
            selected: currentPath.startsWith('/projects'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/projects');
            },
          ),

          AppDrawerItem(
            icon: Icons.inbox_outlined,
            label: 'Local Drafts',
            selected: currentPath.startsWith('/local-gallery'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/local-gallery');
            },
          ),

          const Spacer(),
          const Divider(),

          // ── Sign out ─────────────────────────────────────────────────────
          AppDrawerItem(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            selected: false,
            onTap: () {
              Navigator.of(context).pop();
              context.read<AuthCubit>().logout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
