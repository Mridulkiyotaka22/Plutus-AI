import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../providers/behavioural_provider.dart';

class QuestionnaireDialog extends ConsumerStatefulWidget {
  const QuestionnaireDialog({super.key});

  @override
  ConsumerState<QuestionnaireDialog> createState() =>
      _QuestionnaireDialogState();
}

class _QuestionnaireDialogState extends ConsumerState<QuestionnaireDialog> {
  int _currentStep = 0;
  final Map<String, int> _answers = {};
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionnaireQuestionsProvider);

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: questionsAsync.when(
            data: (questions) {
              if (questions.isEmpty) {
                return const Center(
                    child: Text('No questions configured.',
                        style: TextStyle(color: AppColors.textMuted)));
              }

              final q = questions[_currentStep];
              final progress = (_currentStep + 1) / questions.length;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentStep + 1} of ${questions.length}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textMuted, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    q.text,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  ...q.options.map((opt) {
                    final isSel = _answers[q.id] == opt.score;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _answers[q.id] = opt.score;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primary.withOpacity(0.15)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isSel ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSel
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSel
                                    ? AppColors.primaryLight
                                    : AppColors.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  opt.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSel
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                    fontWeight: isSel
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: () => setState(() => _currentStep--),
                          child: const Text('Previous',
                              style: TextStyle(color: AppColors.textSecondary)),
                        )
                      else
                        const SizedBox.shrink(),
                      ElevatedButton(
                        onPressed: _answers[q.id] == null || _isSubmitting
                            ? null
                            : () async {
                                if (_currentStep < questions.length - 1) {
                                  setState(() => _currentStep++);
                                } else {
                                  // Submit
                                  final navigator = Navigator.of(context);
                                  setState(() => _isSubmitting = true);
                                  final repo =
                                      ref.read(behaviouralRepositoryProvider);
                                  await repo.submitAnswers(_answers);
                                  if (!mounted) return;
                                  setState(() => _isSubmitting = false);
                                  ref.invalidate(behaviouralProfileProvider);
                                  navigator.pop();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(_currentStep < questions.length - 1
                                ? 'Next'
                                : 'Complete Assessment'),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err',
                style: const TextStyle(color: AppColors.negative)),
          ),
        ),
      ),
    );
  }
}
