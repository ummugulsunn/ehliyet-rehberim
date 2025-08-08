import 'dart:convert';
import 'dart:io';

/// Validates exams.json content and produces analysis outputs:
/// - analysis/exams_report.json (detailed JSON report)
/// - analysis/missing_images.csv (CSV of questions likely needing visuals)
///
/// Heuristics:
/// - A question is flagged as needing an image if its text (or any option) contains
///   visual cues (e.g., "şekil", "resim", "görsel", "levha", "işaret",
///   "gösterge", "ikaz ışığı", "yatay işaretleme", "taşıt yolu üzerine çizilen",
///   "dönel kavşak", "şekildeki", "şekle göre") and imageUrl is null.
/// - Hints are generated for what image to provide based on keywords.
/// - Correct answer key is validated to exist in options.
/// - Duplicate questions (same normalized text) are clustered and inconsistencies
///   in answers/explanations are reported.
Future<void> main(List<String> args) async {
  // Paths
  final examsPath =
      '/Users/ummugulsun/Ehliyet Rehberim/ehliyet_rehberim/assets/data/exams.json';
  final analysisDirPath =
      '/Users/ummugulsun/Ehliyet Rehberim/ehliyet_rehberim/analysis';

  final examsFile = File(examsPath);
  if (!examsFile.existsSync()) {
    stderr.writeln('ERROR: exams.json not found at: $examsPath');
    exitCode = 1;
    return;
  }

  final analysisDir = Directory(analysisDirPath);
  if (!analysisDir.existsSync()) {
    analysisDir.createSync(recursive: true);
  }

  final raw = await examsFile.readAsString();
  final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

  final visualKeywords = <String>{
    'şekil',
    'sekil',
    'şekle göre',
    'şekildeki',
    'resim',
    'görsel',
    'levha',
    'işaret',
    'isaret',
    'gösterge',
    'gosterge',
    'ikaz ışığı',
    'ikaz isiği',
    'ikaz isigi',
    'yatay işaretleme',
    'yatay isaretleme',
    'taşıt yolu üzerine çizilen',
    'tasit yolu uzerine cizilen',
    'dönel kavşak',
    'donel kavsak',
    'polisin verdiği işaret',
    'polis işareti',
    'trafik polisi işareti',
  };

  String normalize(String s) {
    final lower = s.toLowerCase().trim();
    // Remove double spaces
    final single = lower.replaceAll(RegExp(r'\s+'), ' ');
    // Remove surrounding punctuation that may vary
    return single.replaceAll(RegExp(r'["\' + "'" + r']'), '');
  }

  bool textIndicatesVisual(String text) {
    final t = text.toLowerCase();
    return visualKeywords.any((k) => t.contains(k));
  }

  String suggestImageHint(String text) {
    final t = text.toLowerCase();
    if (t.contains('gösterge') || t.contains('gosterge') || t.contains('ikaz')) {
      return 'Araç gösterge paneli simgesi/ikaz ışığı görseli';
    }
    if (t.contains('levha') || t.contains('işaret') || t.contains('isaret')) {
      return 'İlgili trafik işaret/levha görseli';
    }
    if (t.contains('yatay işaret') || t.contains('yatay isaret') ||
        t.contains('taşıt yolu üzerine çizilen') ||
        t.contains('tasit yolu uzerine cizilen')) {
      return 'Yol üzeri yatay işaretleme (ör. yaya geçidi, taralı alan) görseli';
    }
    if (t.contains('dönel kavşak') || t.contains('donel kavsak')) {
      return 'Dönel kavşak şeması/görseli';
    }
    if (t.contains('polis') || t.contains('trafik polisi')) {
      return 'Trafik polisinin kol/beden işareti görseli';
    }
    if (t.contains('şekil') || t.contains('sekil') || t.contains('resim') ||
        t.contains('görsel')) {
      return 'Soruda atıf yapılan şekil/resim görseli';
    }
    return 'İlgili görsel (işaret/şekil)';
  }

  final missingImage = <Map<String, dynamic>>[];
  final invalidCorrectKey = <Map<String, dynamic>>[];
  final duplicateClusters = <Map<String, dynamic>>[];

  // For duplicates
  final Map<String, List<Map<String, dynamic>>> normalizedTextToQuestions = {};

  for (final exam in data) {
    final examId = exam['examId']?.toString() ?? 'unknown_exam';
    final questions = (exam['questions'] as List<dynamic>?) ?? const [];
    for (final q in questions) {
      final id = q['id'];
      final text = (q['questionText'] ?? '').toString();
      final imageUrl = q['imageUrl'];
      final options = (q['options'] ?? {}) as Map<String, dynamic>;
      final correctKey = (q['correctAnswerKey'] ?? '').toString();
      final explanation = (q['explanation'] ?? '').toString();
      final category = (q['category'] ?? '').toString();

      // Duplicate clustering
      final norm = normalize(text);
      (normalizedTextToQuestions[norm] ??= <Map<String, dynamic>>[]).add({
        'examId': examId,
        'id': id,
        'text': text,
        'imageUrl': imageUrl,
        'options': options.map((k, v) => MapEntry(k.toString(), v.toString())),
        'correctAnswerKey': correctKey,
        'correctAnswerText': options[correctKey]?.toString(),
        'explanation': explanation,
        'category': category,
      });

      // Missing image heuristic: question text or any option contains visual cue
      final indicatesVisual = textIndicatesVisual(text) ||
          options.values.any((v) => textIndicatesVisual(v.toString()));
      final hasImage = imageUrl != null && imageUrl.toString().trim().isNotEmpty;
      if (indicatesVisual && !hasImage) {
        missingImage.add({
          'examId': examId,
          'id': id,
          'questionText': text,
          'category': category,
          'imageUrl': imageUrl,
          'suggestedImageHint': suggestImageHint(text),
        });
      }

      // Validate correct answer key exists
      final optionKeys = options.keys.map((e) => e.toString()).toSet();
      if (!optionKeys.contains(correctKey)) {
        invalidCorrectKey.add({
          'examId': examId,
          'id': id,
          'questionText': text,
          'category': category,
          'correctAnswerKey': correctKey,
          'availableOptionKeys': optionKeys.toList(),
        });
      }
    }
  }

  // Analyze duplicates for inconsistencies
  for (final entry in normalizedTextToQuestions.entries) {
    final questions = entry.value;
    if (questions.length <= 1) continue;

    final answerSet = <String>{};
    final explanationSet = <String>{};
    for (final q in questions) {
      final ck = q['correctAnswerKey']?.toString() ?? '';
      final answerText = q['correctAnswerText']?.toString() ?? '';
      answerSet.add('$ck::$answerText');
      final exp = q['explanation']?.toString().trim() ?? '';
      if (exp.isNotEmpty) explanationSet.add(exp);
    }

    final hasAnswerConflict = answerSet.length > 1;
    final hasExplanationConflict = explanationSet.length > 1;
    if (hasAnswerConflict || hasExplanationConflict) {
      duplicateClusters.add({
        'questionTextNormalized': entry.key,
        'instances': questions,
        'distinctAnswers': answerSet.toList(),
        'distinctExplanations': explanationSet.toList(),
      });
    }
  }

  final report = {
    'summary': {
      'totalExams': data.length,
      'totalQuestions': normalizedTextToQuestions.values
          .fold<int>(0, (sum, list) => sum + list.length),
      'missingImageCount': missingImage.length,
      'invalidCorrectKeyCount': invalidCorrectKey.length,
      'duplicateConflictClusters': duplicateClusters.length,
    },
    'missingImageQuestions': missingImage,
    'invalidCorrectKeyQuestions': invalidCorrectKey,
    'duplicateConflictClusters': duplicateClusters,
  };

  final jsonReportPath =
      '$analysisDirPath/exams_report.json';
  final csvMissingImagesPath =
      '$analysisDirPath/missing_images.csv';

  await File(jsonReportPath)
      .writeAsString(const JsonEncoder.withIndent('  ').convert(report));

  // CSV export for missing images
  final csvBuffer = StringBuffer();
  csvBuffer.writeln(
      'examId,questionId,category,suggestedImageHint,questionText');
  for (final m in missingImage) {
    String esc(String v) => '"' + v.replaceAll('"', '""') + '"';
    csvBuffer.writeln([
      esc(m['examId']?.toString() ?? ''),
      esc(m['id']?.toString() ?? ''),
      esc(m['category']?.toString() ?? ''),
      esc(m['suggestedImageHint']?.toString() ?? ''),
      esc(m['questionText']?.toString() ?? ''),
    ].join(','));
  }
  await File(csvMissingImagesPath).writeAsString(csvBuffer.toString());

  stdout.writeln('Analysis complete.');
  stdout.writeln('Report: $jsonReportPath');
  stdout.writeln('Missing images CSV: $csvMissingImagesPath');
}

