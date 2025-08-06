import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question_model.dart';

/// Service responsible for loading quiz questions from local JSON file
class QuizService {
  /// Loads questions from the local JSON file
  /// 
  /// Returns a list of Question objects parsed from the JSON data
  /// Throws [PlatformException] if the file cannot be read
  /// Throws [FormatException] if the JSON is malformed
  Future<List<Question>> loadQuestions() async {
    try {
      // Read the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/data/questions.json');
      
      // Decode the JSON string
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      
      // Convert each JSON object to a Question object
      final List<Question> questions = jsonList
          .map((json) => Question.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return questions;
    } on PlatformException catch (e) {
      throw Exception('Failed to load questions: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Failed to parse questions JSON: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error loading questions: $e');
    }
  }
} 