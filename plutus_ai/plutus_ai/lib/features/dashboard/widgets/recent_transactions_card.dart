import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../models/transaction_item.dart';
import '../providers/dashboard_providers.dart';

/// Recent financial transactions card with type filtering.
class RecentTransactionsCard extends ConsumerStatefulWidget {
  const RecentTransactionsCard({super.key});

  @override
  ConsumerState<RecentTransactionsCard> createState() =>
      _RecentTransactionsCardState();
}

class _RecentTransactionsCardState
    extends ConsumerState<RecentTransactionsCard> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSACTION ACTIVITY',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // Filter selector
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['ALL', 'BUYS', 'SELLS', 'DIVIDENDS'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return InkWell(
                      onTap: () => setState(() => _selectedFilter = filter),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          transactionsAsync.when(
            data: (allTransactions) {
              final transactions = allTransactions.where((tx) {
                if (_selectedFilter == 'BUYS') {
                  return tx.type == TransactionType.buy;
                }
                if (_selectedFilter == 'SELLS') {
                  return tx.type == TransactionType.sell;
                }
                if (_selectedFilter == 'DIVIDENDS') {
                  return tx.type == TransactionType.dividend;
                }
                return true;
              }).toList();

              if (transactions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No transactions found for filter.',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppColors.border, height: 16),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isBuy = tx.type == TransactionType.buy;
                  final isSell = tx.type == TransactionType.sell;
                  final isDiv = tx.type == TransactionType.dividend;

                  final IconData iconData;
                  final Color iconColor;
                  final String typeBadge;

                  if (isBuy) {
                    iconData = Icons.add_circle_outline_rounded;
                    iconColor = AppColors.primaryLight;
                    typeBadge = 'BUY';
                  } else if (isSell) {
                    iconData = Icons.remove_circle_outline_rounded;
                    iconColor = AppColors.negative;
                    typeBadge = 'SELL';
                  } else if (isDiv) {
                    iconData = Icons.monetization_on_outlined;
                    iconColor = AppColors.positive;
                    typeBadge = 'DIVIDEND';
                  } else {
                    iconData = Icons.account_balance_wallet_outlined;
                    iconColor = AppColors.market;
                    typeBadge = 'DEPOSIT';
                  }

                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(iconData, size: 18, color: iconColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  tx.symbol,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    typeBadge,
                                    style: TextStyle(
                                      color: iconColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tx.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            (isSell || isDiv)
                                ? '+${currencyFormatter.format(tx.amount)}'
                                : currencyFormatter.format(tx.amount),
                            style: TextStyle(
                              color: isDiv
                                  ? AppColors.positive
                                  : AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormat('MMM dd, yyyy').format(tx.date),
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (err, _) => Center(
              child: Text('Error loading transactions: $err',
                  style: const TextStyle(color: AppColors.negative)),
            ),
          ),
        ],
      ),
    );
  }
}
