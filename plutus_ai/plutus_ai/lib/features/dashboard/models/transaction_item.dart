/// Type of financial transaction.
enum TransactionType { buy, sell, dividend, deposit, withdrawal }

/// Recent transaction entry.
class TransactionItem {
  final String id;
  final TransactionType type;
  final String symbol;
  final String description;
  final double amount;
  final double? shares;
  final double? price;
  final DateTime date;
  final String status;

  const TransactionItem({
    required this.id,
    required this.type,
    required this.symbol,
    required this.description,
    required this.amount,
    this.shares,
    this.price,
    required this.date,
    this.status = 'Completed (DEMO)',
  });
}
