import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../models/alert_model.dart';
import '../providers/alerts_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsListProvider);
    final selectedCat = ref.watch(selectedAlertCategoryProvider);
    final unreadOnly = ref.watch(unreadOnlyFilterProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alerts & Real-Time Intelligence',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Automated portfolio notifications, tax opportunity alerts, and risk warnings',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () async {
                    final repo = ref.read(alertsRepositoryProvider);
                    await repo.markAllAsRead();
                    ref.invalidate(alertsListProvider);
                  },
                  icon: const Icon(Icons.done_all,
                      size: 16, color: AppColors.primaryLight),
                  label: const Text('Mark All Read',
                      style: TextStyle(
                          color: AppColors.primaryLight, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category and Unread Filter Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...['ALL', 'RISK', 'PORTFOLIO', 'RESEARCH', 'MARKET', 'SYSTEM']
                    .map((cat) {
                  final isSel = selectedCat == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    onSelected: (_) => ref
                        .read(selectedAlertCategoryProvider.notifier)
                        .state = cat,
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? Colors.white : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                        color: isSel ? AppColors.primary : AppColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  );
                }),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Unread Only'),
                  selected: unreadOnly,
                  onSelected: (val) =>
                      ref.read(unreadOnlyFilterProvider.notifier).state = val,
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.market.withOpacity(0.2),
                  checkmarkColor: AppColors.market,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color:
                        unreadOnly ? AppColors.market : AppColors.textSecondary,
                    fontWeight:
                        unreadOnly ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                      color: unreadOnly ? AppColors.market : AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Alert Items List
            alertsAsync.when(
              data: (alerts) {
                if (alerts.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              color: AppColors.textMuted, size: 36),
                          SizedBox(height: 12),
                          Text('No alerts match the selected filter.',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: alerts
                      .map((alert) => _buildAlertTile(context, ref, alert))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading alerts: $err',
                  style: const TextStyle(color: AppColors.negative)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTile(
      BuildContext context, WidgetRef ref, AlertModel alert) {
    Color priorityColor = AppColors.market;
    if (alert.priority == 'WARNING') priorityColor = AppColors.warning;
    if (alert.priority == 'CRITICAL') priorityColor = AppColors.negative;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: alert.isRead ? AppColors.card : AppColors.card.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              alert.isRead ? AppColors.border : priorityColor.withOpacity(0.6),
          width: alert.isRead ? 1 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              alert.priority == 'WARNING'
                  ? Icons.warning_amber_rounded
                  : Icons.info_outline,
              color: priorityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          alert.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: alert.isRead
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (!alert.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatDate(alert.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alert.message,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        alert.category,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        if (alert.actionLabel.isNotEmpty &&
                            alert.actionRoute.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              context.go(alert.actionRoute);
                            },
                            child: Text(
                              alert.actionLabel,
                              style: const TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (!alert.isRead)
                          IconButton(
                            tooltip: 'Mark as read',
                            icon: const Icon(Icons.check,
                                size: 16, color: AppColors.textMuted),
                            onPressed: () async {
                              final repo = ref.read(alertsRepositoryProvider);
                              await repo.markAsRead(alert.id);
                              ref.invalidate(alertsListProvider);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
