import '../models/research_model_meta.dart';

class DemoResearch {
  static const List<ResearchModelMeta> defaultModels = [
    ResearchModelMeta(
      modelId: 'IEM-FIN',
      name: 'Information Extraction Model (IEM)',
      architecture: 'Transformer Entity-Linking with FinBERT Sentiment Head',
      description:
          'Extracts structured revenue guidance, capex disclosures, and executive tone from SEC 10-K filings and earnings call transcripts.',
      status: 'EXPERIMENTAL',
      statusDisplay: 'Experimental Offline Testing',
      version: 'v1.2-alpha',
      parametersCount: '110M',
      datasetCoverage: 'SEC Edgar, Refinitiv 2018-2025 Transcripts',
      trainingCutoff: '2025-12-31',
      evaluations: [
        ModelEvaluationModel(
          benchmarkDataset:
              'FinancialPhraseBank + SEC Guidance 2025 Test Split',
          split: 'Out-of-sample Test',
          directionalAccuracy: 78.40,
          f1Score: 0.82,
          evalDate: '2026-01-15',
          notes:
              'High precision on guidance revision extraction; occasional ambiguity on non-standard EBITDA definitions.',
        ),
      ],
    ),
    ResearchModelMeta(
      modelId: 'TIMEFORMER-MTS',
      name: 'TimeFormer Multivariate Forecasting',
      architecture: 'Patch-based Temporal Cross-Attention Network',
      description:
          'Predicts multi-horizon covariance matrices and conditional volatility regimes across 500 liquid US instruments.',
      status: 'PROPOSED',
      statusDisplay: 'Proposed / In Research',
      version: 'v0.3-research',
      parametersCount: '340M',
      datasetCoverage:
          'CRSP Daily Returns, Federal Reserve FRED Macro Data (1990-2025)',
      trainingCutoff: '2025-10-31',
      evaluations: [
        ModelEvaluationModel(
          benchmarkDataset: 'Rolling 60-day Covariance Test 2024-2025',
          split: 'Walk-forward Validation',
          mae: 0.0142,
          sharpeBacktest: 1.68,
          evalDate: '2026-02-01',
          notes:
              'Outperformed classical GARCH(1,1) in heavy-tailed regime transitions.',
        ),
      ],
    ),
    ResearchModelMeta(
      modelId: 'MTSM-MACRO',
      name: 'Multi-Task Sentiment Model (MTSM)',
      architecture: 'Hierarchical State-Space Joint Sentiment & Macro Encoder',
      description:
          'Jointly models central bank communications, bond yield curve inversions, and institutional CFTC positioning.',
      status: 'EXPERIMENTAL',
      statusDisplay: 'Experimental Offline Testing',
      version: 'v0.9-beta',
      parametersCount: '220M',
      datasetCoverage: 'FOMC Minutes, ECB Statements, Treasury Auction Data',
      trainingCutoff: '2025-12-31',
      evaluations: [
        ModelEvaluationModel(
          benchmarkDataset: 'FOMC Rate Decision Shocks (2020-2025)',
          split: 'Event-study Out-of-Sample',
          directionalAccuracy: 73.10,
          f1Score: 0.76,
          evalDate: '2026-02-10',
          notes:
              'Demonstrates superior latency in processing real-time press releases.',
        ),
      ],
    ),
  ];
}
