import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../features/quiz/domain/test_result_model.dart';
import '../utils/logger.dart';

class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();
  factory FileStorageService() => _instance;
  FileStorageService._internal();

  static const String _fileName = 'test_results_backup.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  /// Save results to file (overwrites existing)
  Future<void> saveTestResults(List<TestResult> results) async {
    try {
      final file = await _localFile;
      final jsonStr = TestResult.encodeList(results);
      await file.writeAsString(jsonStr);
      Logger.info(
        'Saved ${results.length} results to file storage: ${file.path}',
      );
    } catch (e) {
      Logger.error('Failed to save results to file', e);
    }
  }

  /// Load results from file
  Future<List<TestResult>> loadTestResults() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        Logger.info('No file backup found at ${file.path}');
        return [];
      }

      final jsonStr = await file.readAsString();
      if (jsonStr.isEmpty) return [];

      Logger.info('Reading from file storage (Length: ${jsonStr.length})');
      return TestResult.decodeList(jsonStr);
    } catch (e) {
      Logger.error('Failed to load results from file', e);
      return [];
    }
  }

  /// Clear backup file
  Future<void> clearBackup() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
        Logger.info('Deleted backup file successfully');
      }
    } catch (e) {
      Logger.error('Failed to delete backup file', e);
    }
  }
}
