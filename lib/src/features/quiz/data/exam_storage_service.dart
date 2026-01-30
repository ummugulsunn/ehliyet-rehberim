import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/unfinished_exam.dart';

final examStorageServiceProvider = Provider<ExamStorageService>((ref) {
  return ExamStorageService();
});

class ExamStorageService {
  static const String _prefix = 'unfinished_exam_';

  Future<void> saveExam(UnfinishedExam exam) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix${exam.examId}', exam.toJson());
  }

  Future<UnfinishedExam?> getUnfinishedExam(String examId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_prefix$examId');
    
    if (jsonStr == null) return null;
    
    try {
      return UnfinishedExam.fromJson(jsonStr);
    } catch (e) {
      // If data is corrupted, clear it
      await deleteUnfinishedExam(examId);
      return null;
    }
  }

  Future<void> deleteUnfinishedExam(String examId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$examId');
  }

  Future<bool> hasUnfinishedExam(String examId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_prefix$examId');
  }
}
