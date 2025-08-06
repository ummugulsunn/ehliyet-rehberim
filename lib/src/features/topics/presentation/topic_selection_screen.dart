import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../quiz/application/quiz_providers.dart';
import '../../quiz/presentation/quiz_screen.dart';

class TopicSelectionScreen extends ConsumerWidget {
  const TopicSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(quizQuestionsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konu Seçimi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: questionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Sorular yüklenirken bir hata oluştu',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(quizQuestionsProvider(null));
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (questions) {
          // Extract unique categories and count questions per category
          final Map<String, int> categoryCounts = {};
          for (final question in questions) {
            categoryCounts[question.category] = (categoryCounts[question.category] ?? 0) + 1;
          }

          final List<MapEntry<String, int>> sortedCategories = categoryCounts.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedCategories.length,
            itemBuilder: (context, index) {
              final category = sortedCategories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      _getCategoryIcon(category.key),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    category.key,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${category.value} soru',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(category: category.key),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Trafik İşaretleri':
        return Icons.traffic;
      case 'Trafik ve Çevre Bilgisi':
        return Icons.directions_car;
      case 'İlk Yardım':
        return Icons.medical_services;
      case 'Motor ve Araç Tekniği':
        return Icons.build;
      case 'Trafik Adabı':
        return Icons.psychology;
      default:
        return Icons.topic;
    }
  }
} 