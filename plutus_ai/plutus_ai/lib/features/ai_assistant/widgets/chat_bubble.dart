import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/ai_message_model.dart';

class ChatBubble extends StatelessWidget {
  final AIMessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: const BoxConstraints(maxWidth: 580),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14).copyWith(
              bottomRight: const Radius.circular(2),
            ),
          ),
          child: Text(
            message.content,
            style:
                const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
        ),
      );
    }

    if (message.isSystem || !message.isInScope) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 620),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.warning.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined,
                      color: AppColors.warning, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Finance Domain Boundary Guardrail',
                    style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.content,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    // Assistant Message
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(18),
        constraints: const BoxConstraints(maxWidth: 660),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14).copyWith(
            bottomLeft: const Radius.circular(2),
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.aiViolet]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 12),
                ),
                const SizedBox(width: 8),
                const Text(
                  'PLUTUS AI',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.aiViolet),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              message.content,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 14),

            // Sources pill list
            if (message.sources.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.sources.map((src) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_outlined,
                            size: 10, color: AppColors.positive),
                        const SizedBox(width: 4),
                        Text(
                          src,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],

            Text(
              message.disclaimers,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
