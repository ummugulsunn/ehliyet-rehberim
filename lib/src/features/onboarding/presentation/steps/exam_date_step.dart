import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/onboarding_providers.dart';
import '../widgets/onboarding_step_layout.dart';

class ExamDateStep extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ExamDateStep({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    final selectedDate = state.examDate;

    // Calculate days left
    int? daysLeft;
    if (selectedDate != null) {
      final now = DateTime.now();
      // Reset time for accurate day calc
      final cleanNow = DateTime(now.year, now.month, now.day);
      final cleanSelected = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      daysLeft = cleanSelected.difference(cleanNow).inDays;
    }

    return OnboardingStepLayout(
      title: 'Sınavın Ne Zaman?',
      subtitle:
          'Sana özel bir çalışma planı oluşturmak ve seni motive etmek için sınav tarihini bilmemiz gerekiyor.',
      bottomWidget: Row(
        children: [
          TextButton(
            onPressed: onBack,
            style: TextButton.styleFrom(minimumSize: const Size(80, 56)),
            child: const Text('Geri'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: selectedDate != null ? onNext : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Devam Et',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Picker Card
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? now.add(const Duration(days: 30)),
                firstDate: now,
                lastDate: now.add(const Duration(days: 365)),
                locale: const Locale('tr', 'TR'),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                ref.read(onboardingStateProvider.notifier).setExamDate(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selectedDate != null
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width: selectedDate != null ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDate == null
                              ? 'Tarih Seçin'
                              : DateFormat(
                                  'd MMMM yyyy',
                                  'tr_TR',
                                ).format(selectedDate),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: selectedDate == null
                                ? Colors.grey
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (selectedDate == null)
                          const Text(
                            'Henüz belli değilse tahmini seç',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Result Card (Days Left)
          if (daysLeft != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B48FF), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B48FF).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$daysLeft Gün Kaldı!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    daysLeft > 60
                        ? 'Rahat ol, önünde uzun bir zaman var. Düzenli çalışarak rahatça yetiştirirsin.'
                        : daysLeft > 30
                        ? 'Tam zamanı! Şimdi başlarsan konuları rahatça bitirip bol bol deneme çözebilirsin.'
                        : 'Zaman daralıyor! Sıkı bir programla eksiklerini kapatıp sınavı geçebilirsin.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          if (selectedDate == null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: TextButton(
                onPressed: () {
                  // Set a placeholder date (e.g., 30 days from now)
                  ref
                      .read(onboardingStateProvider.notifier)
                      .setExamDate(
                        DateTime.now().add(const Duration(days: 30)),
                      );
                },
                child: const Text('Tarihim henüz belli değil'),
              ),
            ),
        ],
      ),
    );
  }
}
