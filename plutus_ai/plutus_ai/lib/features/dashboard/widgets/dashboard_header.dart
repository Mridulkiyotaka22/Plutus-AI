import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';

/// Top header banner for the Financial Command Center.
class DashboardHeader extends ConsumerWidget {
  final VoidCallback? onRefresh;

  const DashboardHeader({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(appEnvironmentProvider);
    final isDemo = environment == Environment.demo;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.token_rounded,
                                size: 12, color: AppColors.primaryLight),
                            SizedBox(width: 5),
                            Text(
                              'FINANCIAL COMMAND CENTER',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isDemo ? AppColors.warning : AppColors.market).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: (isDemo ? AppColors.warning : AppColors.market).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          isDemo ? 'DEMO DATA' : 'API MODE',
                          style: TextStyle(
                            color: isDemo ? AppColors.warning : AppColors.market,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Portfolio Intelligence & Command Center',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'A consolidated view of your portfolio, latest available market data and financial intelligence.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!isNarrow) ...[
              const SizedBox(width: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.go('/ai'),
                    icon: const Icon(Icons.auto_awesome,
                        size: 16, color: AppColors.aiViolet),
                    label: const Text('Ask PLUTUS AI'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.aiViolet.withValues(alpha: 0.4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/portfolio'),
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: const Text('Manage Assets'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
