import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';

/// Premium metric display card for portfolio KPIs.
class MetricCard extends StatelessWidget {
  final String title;
  final double amount;
  final double? changeAmount;
  final double? changePercentage;
  final bool isCurrency;
  final IconData? icon;
  final Color? accentColor;
  final String badgeText;
  final String currencySymbol;
  final String? unavailableLabel;

  const MetricCard({
    super.key,
    required this.title,
    required this.amount,
    this.changeAmount,
    this.changePercentage,
    this.isCurrency = true,
    this.icon,
    this.accentColor,
    this.badgeText = 'API',
    this.currencySymbol = '\$',
    this.unavailableLabel,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: currencySymbol, decimalDigits: 2);
    final percentFormatter =
        NumberFormat.decimalPatternDigits(decimalDigits: 2);

    final isPositive = (changeAmount ?? 0) >= 0;
    final changeColor = isPositive ? AppColors.positive : AppColors.negative;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (accentColor ?? AppColors.primary)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon,
                          size: 16,
                          color: accentColor ?? AppColors.primaryLight),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            unavailableLabel ?? (isCurrency
                ? currencyFormatter.format(amount)
                : '${percentFormatter.format(amount)}%'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (unavailableLabel == null && (changeAmount != null || changePercentage != null)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: changeColor,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    changeAmount != null
                        ? '${isPositive ? '+' : ''}${currencyFormatter.format(changeAmount)} (${isPositive ? '+' : ''}${percentFormatter.format(changePercentage ?? 0)}%)'
                        : '${isPositive ? '+' : ''}${percentFormatter.format(changePercentage ?? 0)}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'today',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
