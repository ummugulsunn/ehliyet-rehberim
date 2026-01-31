import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehliyet_rehberim/src/features/study_guides/domain/study_guide_model.dart';
import 'package:ehliyet_rehberim/src/features/quiz/application/quiz_providers.dart';

final studyGuidesProvider = FutureProvider<List<StudyGuide>>((ref) async {
  final service = ref.watch(quizRepositoryProvider);
  return service.loadStudyGuides();
});
