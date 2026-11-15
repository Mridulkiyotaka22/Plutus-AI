import '../models/alert_model.dart';

class DemoAlerts {
  static List<AlertModel> get defaultAlerts => [
        AlertModel(
          id: 'alt-001',
          title: 'Asset Concentration Warning',
          message:
              'NVIDIA (NVDA) constitutes 25.98% of your total portfolio value, exceeding the recommended single-asset diversification limit of 20%.',
          priority: 'WARNING',
          category: 'RISK',
          isRead: false,
          actionLabel: 'Simulate Rebalancing',
          actionRoute: '/wealth',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AlertModel(
          id: 'alt-002',
          title: 'Tax-Loss Harvesting Opportunity Detected',
          message:
              'Vanguard Total Bond ETF (BND) has an unrealized loss of -\$1,365.00 available to offset 2026 taxable capital gains.',
          priority: 'INFO',
          category: 'PORTFOLIO',
          isRead: false,
          actionLabel: 'View Tax Simulator',
          actionRoute: '/wealth',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        AlertModel(
          id: 'alt-003',
          title: 'TimeFormer Model Update Available',
          message:
              'Experimental model TimeFormer-MTS v0.3 walk-forward validation completed with MAE of 0.0142 on 2025 equity returns.',
          priority: 'INFO',
          category: 'RESEARCH',
          isRead: true,
          actionLabel: 'Inspect Evaluation',
          actionRoute: '/research',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
}
