import 'package:flutter/material.dart';

/// Asset category allocation slice in the portfolio.
class AssetAllocationItem {
  final String category;
  final double amount;
  final double percentage;
  final Color color;
  final int assetCount;

  const AssetAllocationItem({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.assetCount,
  });
}
