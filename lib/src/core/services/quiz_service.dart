import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question_model.dart';
import '../models/exam_model.dart';

/// Service responsible for loading quiz questions from local JSON file
class QuizService {
  /// Load all exams from assets/data/exams.json
  Future<List<Exam>> loadExams() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/exams.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((e) => Exam.fromJson(e as Map<String, dynamic>)).toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to load exams: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Failed to parse exams JSON: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error loading exams: $e');
    }
  }

  /// Load questions for a specific exam
  Future<List<Question>> loadQuestionsForExam(String examId) async {
    final exams = await loadExams();
    
    // Special handling for 'karma' examId - aggregate all questions from all exams
    if (examId == 'karma') {
      final List<Question> allQuestions = [];
      for (final exam in exams) {
        allQuestions.addAll(exam.questions.map((q) => q.withExamId(exam.examId)));
      }
      return allQuestions;
    }
    
    // Regular exam lookup
    final exam = exams.firstWhere(
      (e) => e.examId == examId, 
      orElse: () => Exam(examId: examId, examName: 'Unknown', questions: const [])
    );
    return exam.questions.map((q) => q.withExamId(exam.examId)).toList();
  }
} 