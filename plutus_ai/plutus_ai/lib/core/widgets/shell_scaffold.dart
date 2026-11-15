import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';

import '../../config/env_config.dart';
import '../../theme/app_colors.dart';

class ShellScaffold extends ConsumerWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  static const double _sidebarWidth = 252;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1000;
        if (isCompact) {
          return Scaffold(
            drawer: Drawer(
              backgroundColor: AppColors.surface,
              child: SafeArea(child: _buildSidebar(context, currentPath)),
            ),
            appBar: AppBar(
              titleSpacing: 0,
              title: const Text('PLUTUS AI'),
              actions: _buildTopBarActions(context, ref),
            ),
            body: _buildContent(context),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: _sidebarWidth,
                child: _buildSidebar(context, currentPath),
              ),
              const VerticalDivider(width: 1, color: AppColors.border),
              Expanded(
                child: Column(
                  children: [
                    _buildDesktopTopBar(context, ref),
                    Expanded(child: _buildContent(context)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context, String currentPath) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 18, 24),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35)),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.primaryLight, size: 21),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PLUTUS AI',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1)),
                      SizedBox(height: 2),
                      Text('FINANCIAL INTELLIGENCE',
                          style: TextStyle(
                              fontSize: 8,
                              letterSpacing: 1.15,
                              color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 18, 9),
            child: Text('WORKSPACE',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _navItem(context, currentPath, '/', Icons.grid_view_rounded,
                    'Overview'),
                _navItem(context, currentPath, '/markets',
                    Icons.show_chart_rounded, 'Market Terminal'),
                _navItem(context, currentPath, '/portfolio',
                    Icons.pie_chart_outline_rounded, 'My Portfolio'),
                _navItem(context, currentPath, '/watchlists',
                    Icons.bookmarks_outlined, 'Watchlists'),
                _navItem(context, currentPath, '/ai', Icons.auto_awesome,
                    'PLUTUS AI',
                    accent: AppColors.aiViolet),
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 22, 8, 9),
                  child: Text('INTELLIGENCE',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3)),
                ),
                _navItem(context, currentPath, '/behaviour',
                    Icons.psychology_outlined, 'Behavioural Finance'),
                _navItem(context, currentPath, '/risk',
                    Icons.health_and_safety_outlined, 'Risk Intelligence'),
                _navItem(context, currentPath, '/wealth',
                    Icons.account_balance_outlined, 'Wealth & Tax'),
                _navItem(context, currentPath, '/research',
                    Icons.query_stats_rounded, 'Research Intelligence'),
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 22, 8, 9),
                  child: Text('PREFERENCES',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3)),
                ),
                _navItem(context, currentPath, '/alerts',
                    Icons.notifications_none_rounded, 'Alerts & Activity'),
                _navItem(context, currentPath, '/settings', Icons.tune_rounded,
                    'Settings'),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.science_outlined,
                    color: AppColors.warning, size: 17),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    EnvConfig.isDemo ? 'DEMO WORKSPACE' : 'API MODE SELECTED',
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: AppColors.textSecondary),
                  ),
                ),
                Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: AppColors.warning, shape: BoxShape.circle)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String currentPath, String path,
      IconData icon, String label,
      {Color? accent}) {
    final selected = currentPath == path ||
        (path != '/' && currentPath.startsWith('$path/'));
    final foreground =
        selected ? (accent ?? AppColors.primaryLight) : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () {
            context.go(path);
            if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            height: 43,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: selected
                  ? Border.all(
                      color:
                          (accent ?? AppColors.primary).withValues(alpha: 0.24))
                  : null,
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(label,
                        style: TextStyle(
                            color: selected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500))),
                if (selected)
                  Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                          color: accent ?? AppColors.primaryLight,
                          shape: BoxShape.circle)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTopBar(BuildContext context, WidgetRef ref) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Your financial workspace',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          SizedBox(
            width: 250,
            height: 37,
            child: TextField(
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search markets, assets...',
                prefixIcon: const Icon(Icons.search, size: 17),
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
              onSubmitted: (value) => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(
                      content: Text(
                          'Search will connect to the market API: $value'))),
            ),
          ),
          const SizedBox(width: 12),
          ..._buildTopBarActions(context, ref),
        ],
      ),
    );
  }

  List<Widget> _buildTopBarActions(BuildContext context, WidgetRef ref) => [
        IconButton(
          tooltip: 'Alerts & Activity',
          onPressed: () => context.go('/alerts'),
          icon: const Icon(Icons.notifications_none_rounded,
              color: AppColors.textSecondary, size: 20),
        ),
        const SizedBox(width: 7),
        PopupMenuButton<String>(
          tooltip: 'Account menu',
          onSelected: (value) async {
            if (value == 'settings' || value == 'profile') {
              context.go('/settings');
            } else if (value == 'logout') {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'profile', child: Text('Profile & Settings')),
            PopupMenuItem(value: 'settings', child: Text('System Configuration')),
            PopupMenuDivider(),
            PopupMenuItem(value: 'logout', child: Text('Sign out')),
          ],
          child: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person_outline, size: 17, color: Colors.white)),
        ),
      ];

  Widget _buildContent(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}
