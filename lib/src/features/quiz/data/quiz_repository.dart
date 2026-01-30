import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/question_model.dart';
import '../domain/exam_model.dart';
import '../../traffic_signs/domain/traffic_sign_model.dart';
import '../../study_guides/domain/study_guide_model.dart';

/// Service responsible for loading quiz questions from local JSON file
class QuizRepository {
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
    
    // Special handling for 'karma' or 'exam_simulation' - aggregate and randomize
    if (examId == 'karma' || examId == 'exam_simulation') {
      final List<Question> allQuestions = [];
      int uniqueIdCounter = 1;
      for (final exam in exams) {
        for (final question in exam.questions) {
          // First add examId, then assign new unique ID (which preserves original ID)
          final uniqueQuestion = question
              .withExamId(exam.examId)
              .withNewId(uniqueIdCounter++);
              
          allQuestions.add(uniqueQuestion);
        }
      }
      
      allQuestions.shuffle();
      
      // If exam_simulation, take exactly 50 questions
      if (examId == 'exam_simulation') {
        return allQuestions.take(50).toList();
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

  /// Load traffic signs categories from assets/data/traffic_signs.json
  Future<List<TrafficSignCategory>> loadTrafficSigns() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/traffic_signs.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => TrafficSignCategory.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on PlatformException catch (e) {
      throw Exception('Failed to load traffic signs: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Failed to parse traffic signs JSON: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error loading traffic signs: $e');
    }
  }

  /// Load study guides from assets/data/study_guides.json
  Future<List<StudyGuide>> loadStudyGuides() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/study_guides.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => StudyGuide.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on PlatformException catch (e) {
      throw Exception('Failed to load study guides: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Failed to parse study guides JSON: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error loading study guides: $e');
    }
  }
} 