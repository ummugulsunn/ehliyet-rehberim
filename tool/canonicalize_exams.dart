import 'dart:convert';
import 'dart:io';

/// Canonicalizes exams.json by:
/// - Grouping identical questions by normalized text AND normalized options layout
/// - Selecting majority correctAnswerKey within each group
/// - Selecting majority explanation (tie-breaking by longest string)
/// - Updating all instances in-place
/// - Leaving questions with invalid correctAnswerKey (not in options) unchanged
///
/// Outputs:
/// - Writes updated file back to assets/data/exams.json (after creating a timestamped backup)
/// - Writes a change report to analysis/canonicalize_report.json
Future<void> main(List<String> args) async {
  final examsPath =
      '/Users/ummugulsun/Ehliyet Rehberim/ehliyet_rehberim/assets/data/exams.json';
  final analysisDirPath =
      '/Users/ummugulsun/Ehliyet Rehberim/ehliyet_rehberim/analysis';

  final file = File(examsPath);
  if (!file.existsSync()) {
    stderr.writeln('ERROR: exams.json not found at: $examsPath');
    exit(1);
  }
  final analysisDir = Directory(analysisDirPath);
  if (!analysisDir.existsSync()) analysisDir.createSync(recursive: true);

  final raw = await file.readAsString();
  final List<dynamic> exams = jsonDecode(raw) as List<dynamic>;

  String normalize(String s) {
    final lower = s.toLowerCase().trim();
    return lower.replaceAll(RegExp(r'\s+'), ' ');
  }

  String normalizeOptions(Map<String, dynamic> options) {
    final entries = options.entries
        .map((e) => '${e.key}:${normalize(e.value.toString())}')
        .toList()
      ..sort();
    return entries.join('|');
  }

  T majority<T>(Iterable<T> items) {
    final counts = <T, int>{};
    for (final i in items) {
      counts[i] = (counts[i] ?? 0) + 1;
    }
    T? best;
    var bestCount = -1;
    counts.forEach((k, v) {
      if (v > bestCount) {
        best = k;
        bestCount = v;
      }
    });
    return best as T;
  }

  String majorityExplanation(Iterable<String> exps) {
    final counts = <String, int>{};
    for (final e in exps) {
      final key = e.trim();
      if (key.isEmpty) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) return '';
    // Choose highest count; tie -> longest
    var best = '';
    var bestCount = -1;
    counts.forEach((k, v) {
      if (v > bestCount || (v == bestCount && k.length > best.length)) {
        best = k;
        bestCount = v;
      }
    });
    return best;
  }

  final grouped = <String, List<Map<String, dynamic>>>{};
  for (final exam in exams) {
    final examId = exam['examId']?.toString() ?? 'unknown';
    final questions = (exam['questions'] as List<dynamic>?);
    if (questions == null) continue;
    for (final q in questions) {
      final text = (q['questionText'] ?? '').toString();
      final options = (q['options'] ?? {}) as Map<String, dynamic>;
      final groupKey = '${normalize(text)}||${normalizeOptions(options)}';
      final enriched = Map<String, dynamic>.from(q);
      enriched['__examId'] = examId;
      grouped.putIfAbsent(groupKey, () => <Map<String, dynamic>>[]).add(enriched);
    }
  }

  final changes = <Map<String, dynamic>>[];
  final skippedInvalidKeys = <Map<String, dynamic>>[];

  // Compute canonical values per group
  final canonicalPerGroup = <String, Map<String, String>>{};
  grouped.forEach((key, list) {
    final options = (list.first['options'] as Map<String, dynamic>);
    final optionKeys = options.keys.map((e) => e.toString()).toSet();
    final keyVotes = list
        .map((q) => q['correctAnswerKey']?.toString() ?? '')
        .where((k) => optionKeys.contains(k))
        .toList();
    if (keyVotes.isEmpty) {
      // Cannot decide canonical key if none of the keys are valid
      canonicalPerGroup[key] = {
        'correctAnswerKey': '',
        'explanation': majorityExplanation(
            list.map((q) => (q['explanation'] ?? '').toString())),
      };
      return;
    }
    final canonicalKey = majority(keyVotes);
    final canonicalExplanation = majorityExplanation(
        list.map((q) => (q['explanation'] ?? '').toString()));
    canonicalPerGroup[key] = {
      'correctAnswerKey': canonicalKey,
      'explanation': canonicalExplanation,
    };
  });

  // Apply canonical values
  for (final exam in exams) {
    final examId = exam['examId']?.toString() ?? 'unknown';
    final questions = (exam['questions'] as List<dynamic>?);
    if (questions == null) continue;
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i] as Map<String, dynamic>;
      final text = (q['questionText'] ?? '').toString();
      final options = (q['options'] ?? {}) as Map<String, dynamic>;
      final optionKeys = options.keys.map((e) => e.toString()).toSet();
      final groupKey = '${normalize(text)}||${normalizeOptions(options)}';
      final canon = canonicalPerGroup[groupKey]!;
      final newKey = canon['correctAnswerKey'] ?? '';
      final newExp = canon['explanation'] ?? '';

      final currentKey = (q['correctAnswerKey'] ?? '').toString();
      final currentExp = (q['explanation'] ?? '').toString();

      if (newKey.isEmpty) {
        // skip; also track invalid
        if (!optionKeys.contains(currentKey)) {
          skippedInvalidKeys.add({
            'examId': examId,
            'id': q['id'],
            'questionText': text,
            'currentCorrectAnswerKey': currentKey,
            'availableOptionKeys': optionKeys.toList(),
          });
        }
        continue;
      }

      var changed = false;
      if (currentKey != newKey && optionKeys.contains(newKey)) {
        q['correctAnswerKey'] = newKey;
        changed = true;
      }
      if (newExp.isNotEmpty && currentExp != newExp) {
        q['explanation'] = newExp;
        changed = true;
      }
      if (changed) {
        changes.add({
          'examId': examId,
          'id': q['id'],
          'questionText': text,
          'oldCorrectAnswerKey': currentKey,
          'newCorrectAnswerKey': q['correctAnswerKey'],
          'oldExplanation': currentExp,
          'newExplanation': q['explanation'],
        });
      }
      questions[i] = q;
    }
  }

  // Backup original
  final backupPath = '$examsPath.bak.${DateTime.now().toIso8601String()}';
  await File(backupPath).writeAsString(raw);
  // Write updated
  final encoder = const JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(exams));

  // Report
  final report = {
    'changesCount': changes.length,
    'skippedInvalidKeysCount': skippedInvalidKeys.length,
    'changes': changes,
    'skippedInvalidKeys': skippedInvalidKeys,
  };
  await File('$analysisDirPath/canonicalize_report.json')
      .writeAsString(encoder.convert(report));

  stdout.writeln('Canonicalization complete. Changes: \'${changes.length}\'.');
  stdout.writeln('Backup: $backupPath');
  stdout.writeln('Report: $analysisDirPath/canonicalize_report.json');
}

