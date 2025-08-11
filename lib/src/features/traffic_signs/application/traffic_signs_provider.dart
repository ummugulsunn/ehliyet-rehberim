import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/traffic_sign_model.dart';
import '../../quiz/application/quiz_providers.dart';

/// Future provider that loads traffic sign categories from assets
final trafficSignsProvider = FutureProvider<List<TrafficSignCategory>>((ref) async {
  final quizService = ref.read(quizServiceProvider);
  return quizService.loadTrafficSigns();
});


