import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../models/market_instrument.dart';
import '../providers/markets_provider.dart';
import '../widgets/market_chart_view.dart';
import '../widgets/technical_stats_panel.dart';

class MarketsScreen extends ConsumerWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instrumentsAsync = ref.watch(marketInstrumentsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedSymbol = ref.watch(selectedInstrumentSymbolProvider);
    final selectedRange = ref.watch(selectedMarketRangeProvider);
    final detailAsync = ref.watch(selectedInstrumentDetailProvider);
    final appEnvironment = ref.watch(appEnvironmentProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 950;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header and Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Market Terminal',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Latest available prices, historical OHLCV charts and market context',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.market.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.market.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.wifi_tethering,
                              size: 14, color: AppColors.market),
                          SizedBox(width: 6),
                          Text(
                            appEnvironment == Environment.demo ? 'DEMO MARKET DATA' : 'YFINANCE • LAST AVAILABLE',
                            style: TextStyle(
                                color: AppColors.market,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search & Category Filters
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 38,
                      child: TextField(
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 13),
                        onChanged: (val) =>
                            ref.read(searchQueryProvider.notifier).state = val,
                        decoration: InputDecoration(
                          hintText: 'Search ticker or company...',
                          hintStyle: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.textMuted, size: 18),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          filled: true,
                          fillColor: AppColors.card,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: AppColors.border)),
                        ),
                      ),
                    ),
                    ...AssetCategory.values.map((cat) {
                      final isSel = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat.label),
                        selected: isSel,
                        onSelected: (_) => ref
                            .read(selectedCategoryProvider.notifier)
                            .state = cat,
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.white : AppColors.textSecondary,
                        ),
                        side: BorderSide(
                            color:
                                isSel ? AppColors.primary : AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Main Content
                if (isCompact) ...[
                  // Mobile / Compact: Chart first, then list
                  detailAsync.when(
                    data: (detail) => Column(
                      children: [
                        MarketChartView(
                          instrument: detail,
                          selectedRange: selectedRange,
                          onRangeChanged: (range) => ref.read(selectedMarketRangeProvider.notifier).state = range,
                        ),
                        const SizedBox(height: 16),
                        TechnicalStatsPanel(instrument: detail),
                        const SizedBox(height: 16),
                      ],
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error: $err',
                        style: const TextStyle(color: AppColors.negative)),
                  ),
                  _buildInstrumentsList(ref, instrumentsAsync, selectedSymbol),
                ] else ...[
                  // Desktop: 2-column layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Instruments List
                      SizedBox(
                        width: 380,
                        child: _buildInstrumentsList(
                            ref, instrumentsAsync, selectedSymbol),
                      ),
                      const SizedBox(width: 20),
                      // Right: Chart and Technical Stats
                      Expanded(
                        child: detailAsync.when(
                          data: (detail) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MarketChartView(
                          instrument: detail,
                          selectedRange: selectedRange,
                          onRangeChanged: (range) => ref.read(selectedMarketRangeProvider.notifier).state = range,
                        ),
                              const SizedBox(height: 20),
                              TechnicalStatsPanel(instrument: detail),
                            ],
                          ),
                          loading: () => const SizedBox(
                            height: 400,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (err, _) => Text('Error: $err',
                              style:
                                  const TextStyle(color: AppColors.negative)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstrumentsList(
    WidgetRef ref,
    AsyncValue<List<MarketInstrument>> asyncList,
    String selectedSymbol,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Watchlist / Instruments',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                ),
                Text(
                  'Select an instrument to load its quote',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          asyncList.when(
            data: (instruments) {
              if (instruments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No instruments match the selected criteria.',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: instruments.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, idx) {
                  final inst = instruments[idx];
                  final isSel = inst.symbol == selectedSymbol;
                  final color =
                      inst.isPositive ? AppColors.positive : AppColors.negative;

                  return InkWell(
                    onTap: () {
                      ref
                          .read(selectedInstrumentSymbolProvider.notifier)
                          .state = inst.symbol;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      color: isSel
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      inst.symbol,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSel
                                            ? AppColors.primaryLight
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      inst.exchange,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  inst.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                inst.hasQuote ? inst.formatPrice(inst.currentPrice) : 'Select to load',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                inst.hasQuote ? '${inst.isPositive ? "+" : ""}${inst.changePercent.toStringAsFixed(2)}%' : '—',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $err',
                  style:
                      const TextStyle(color: AppColors.negative, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
