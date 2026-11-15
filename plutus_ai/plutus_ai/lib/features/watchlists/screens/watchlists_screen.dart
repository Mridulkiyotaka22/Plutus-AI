import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../providers/watchlists_provider.dart';
import '../widgets/create_watchlist_dialog.dart';

class WatchlistsScreen extends ConsumerWidget {
  const WatchlistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistsAsync = ref.watch(watchlistsListProvider);
    final selectedId = ref.watch(selectedWatchlistIdProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: watchlistsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No watchlists found.',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const CreateWatchlistDialog()),
                    child: const Text('Create First Watchlist'),
                  ),
                ],
              ),
            );
          }

          final activeWl = lists.firstWhere(
            (w) => w.id == selectedId,
            orElse: () => lists.first,
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Market Watchlists',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Track customized baskets of equities, crypto, and fixed income instruments',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const CreateWatchlistDialog()),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New Watchlist'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Watchlist tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: lists.map((wl) {
                      final isSel = wl.id == activeWl.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(wl.name),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? Colors.white.withOpacity(0.2)
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${wl.items.length}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSel
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          selected: isSel,
                          onSelected: (_) => ref
                              .read(selectedWatchlistIdProvider.notifier)
                              .state = wl.id,
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.normal,
                            color:
                                isSel ? Colors.white : AppColors.textSecondary,
                          ),
                          side: BorderSide(
                              color:
                                  isSel ? AppColors.primary : AppColors.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Table of items in selected watchlist
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${activeWl.name} (${activeWl.items.length} items)',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                _showAddSymbolDialog(context, ref, activeWl.id),
                            icon: const Icon(Icons.add_circle_outline,
                                size: 16, color: AppColors.primaryLight),
                            label: const Text('Add Symbol',
                                style: TextStyle(
                                    color: AppColors.primaryLight,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (activeWl.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'This watchlist is empty. Click "Add Symbol" to add tracked instruments.',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13),
                            ),
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 38,
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 52,
                            horizontalMargin: 8,
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(
                                  label: Text('Ticker / Instrument',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12))),
                              DataColumn(
                                  label: Text('Current Price',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12))),
                              DataColumn(
                                  label: Text('24h Change',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12))),
                              DataColumn(
                                  label: Text('Exchange',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12))),
                              DataColumn(
                                  label: Text('Investment Thesis / Notes',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12))),
                              DataColumn(
                                  label: Text('Actions',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12))),
                            ],
                            rows: activeWl.items.map((item) {
                              final inst = item.instrument;
                              final isPos = inst.isPositive;
                              final color = isPos
                                  ? AppColors.positive
                                  : AppColors.negative;

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(inst.symbol,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                                fontSize: 13)),
                                        Text(inst.name,
                                            style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(
                                      '\$${inst.currentPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold))),
                                  DataCell(
                                    Text(
                                      '${isPos ? "+" : ""}${inst.changePercent.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                          color: color,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataCell(Text(inst.exchange,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12))),
                                  DataCell(
                                    Text(
                                      item.notes.isNotEmpty ? item.notes : '—',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      tooltip: 'Remove from watchlist',
                                      icon: const Icon(Icons.delete_outline,
                                          size: 18, color: AppColors.negative),
                                      onPressed: () async {
                                        final repo = ref
                                            .read(watchlistsRepositoryProvider);
                                        await repo.removeItem(
                                            activeWl.id, item.id);
                                        ref.invalidate(watchlistsListProvider);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error loading watchlists: $err',
              style: const TextStyle(color: AppColors.negative)),
        ),
      ),
    );
  }

  void _showAddSymbolDialog(
      BuildContext context, WidgetRef ref, String watchlistId) {
    final symbolController = TextEditingController(text: 'GOOGL');
    final notesController =
        TextEditingController(text: 'AI hyperscaler infrastructure');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Instrument to Watchlist',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: symbolController,
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Ticker Symbol (e.g. GOOGL, NVDA, BTC)',
                  labelStyle: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Thesis / Rationale',
                  labelStyle: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final sym = symbolController.text.trim().toUpperCase();
                      if (sym.isNotEmpty) {
                        final navigator = Navigator.of(ctx);
                        final repo = ref.read(watchlistsRepositoryProvider);
                        await repo.addItem(watchlistId, sym,
                            notes: notesController.text.trim());
                        ref.invalidate(watchlistsListProvider);
                        navigator.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
