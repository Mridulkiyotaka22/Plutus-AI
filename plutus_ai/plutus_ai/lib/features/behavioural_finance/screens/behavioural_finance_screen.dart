import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../models/behavioural_models.dart';
import '../providers/behavioural_provider.dart';
import '../widgets/questionnaire_dialog.dart';

class BehaviouralFinanceScreen extends ConsumerWidget {
  const BehaviouralFinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(behaviouralProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: profileAsync.when(
        data: (profile) => _buildContent(context, ref, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error loading profile: $err',
              style: const TextStyle(color: AppColors.negative)),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, BehaviouralProfileModel profile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 950;

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
                        'Behavioural Finance & Risk Psychology',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cognitive bias diagnostics, loss aversion scoring, and trade discipline tracking',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const QuestionnaireDialog(),
                      );
                    },
                    icon: const Icon(Icons.psychology, size: 18),
                    label: const Text('Retake Assessment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Composite Score Overview Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.card,
                      AppColors.primaryDark.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.15),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${profile.compositeScore}',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                profile.riskCategory,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.positive.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'CALIBRATED',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.positive),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            profile.summary,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KPI Bias Breakdown
              Wrap(
                spacing: 16,
                runSpacing: 14,
                children: [
                  _buildMetricCard(
                      'Loss Aversion Index',
                      '${profile.lossAversionScore}/100',
                      'Moderate Resilience',
                      AppColors.market),
                  _buildMetricCard(
                      'Overconfidence Bias',
                      '${profile.overconfidenceScore}/100',
                      'Low Turnover Risk',
                      AppColors.positive),
                  _buildMetricCard(
                      'Panic Propensity',
                      profile.panicSellingPropensity,
                      'Stress Tested',
                      AppColors.aiViolet),
                  _buildMetricCard(
                      'Discipline Gap',
                      '${profile.selfReportedScore - profile.tradeObservedScore} pts',
                      'Self vs Observed',
                      AppColors.warning),
                ],
              ),
              const SizedBox(height: 20),

              // Self vs Observed Discrepancy Card & Behavioral Coaching
              if (isCompact) ...[
                _buildDiscrepancyCard(profile),
                const SizedBox(height: 20),
                _buildCoachingCard(),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDiscrepancyCard(profile)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildCoachingCard()),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
      String title, String val, String subtitle, Color color) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(val,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDiscrepancyCard(BehaviouralProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Self-Reported vs. Trade-Observed Discrepancy',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Compares theoretical willingness to take risk against empirical trade holding times.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          _buildBarRow('Self-Reported Survey Score', profile.selfReportedScore,
              AppColors.primary),
          const SizedBox(height: 16),
          _buildBarRow('Trade-Observed Execution Score',
              profile.tradeObservedScore, AppColors.aiViolet),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.market),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '7-point gap indicates slight overestimation of downside comfort during rapid market pullbacks.',
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarRow(String label, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            Text('$score / 100',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildCoachingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Behavioral Safeguards & Coaching',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          SizedBox(height: 6),
          Text(
            'Algorithmic guardrails configured to protect against emotional errors.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          SizedBox(height: 16),
          _CoachingTip(
            icon: Icons.timer_outlined,
            title: '24-Hour Cooling-Off Rule on Large Sells',
            description:
                'Enforces a 24h delay on liquidating positions during days where equity drawdown exceeds -3.5%.',
          ),
          SizedBox(height: 12),
          _CoachingTip(
            icon: Icons.balance_outlined,
            title: 'Automatic Profit Harvesting Bands',
            description:
                'Triggers disciplined rebalancing reminders whenever any single holding exceeds 25% portfolio weight.',
          ),
          SizedBox(height: 12),
          _CoachingTip(
            icon: Icons.shield_outlined,
            title: 'Dollar-Cost Averaging Buffer',
            description:
                'Deploys excess cash in pre-committed 25% tranches over 4 weeks to avoid peak timing anxiety.',
          ),
        ],
      ),
    );
  }
}

class _CoachingTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _CoachingTip(
      {required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(description,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
