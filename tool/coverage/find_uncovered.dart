// ignore_for_file: avoid_print

import 'dart:io';

/// Finds the top uncovered business-logic files from coverage/lcov.info.
void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('coverage/lcov.info not found. Run "flutter test --coverage" first.');
    return;
  }

  final lines = file.readAsLinesSync();
  final results = <Map<String, dynamic>>[];

  String? currentFile;
  int currentLF = 0;
  int currentLH = 0;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).replaceAll('\\', '/');
      currentLF = 0;
      currentLH = 0;
    } else if (line.startsWith('LF:')) {
      currentLF = int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      currentLH = int.parse(line.substring(3));
    } else if (line == 'end_of_record') {
      if (currentFile != null) {
        final isGenerated = currentFile.endsWith('.g.dart') ||
            currentFile.contains('.freezed.dart') ||
            currentFile.contains('/generated/') ||
            currentFile.contains('lib/generated/');
        final isBiz = !currentFile.contains('/presentation/') &&
            !currentFile.contains('/widgets/') &&
            !currentFile.endsWith('_screen.dart');
        if (!isGenerated && isBiz && currentLF > 0) {
          final missed = currentLF - currentLH;
          if (missed > 0) {
            results.add({
              'file': currentFile,
              'lf': currentLF,
              'lh': currentLH,
              'missed': missed,
              'pct': (currentLH / currentLF * 100),
            });
          }
        }
      }
    }
  }

  // Sort by most missed lines
  results.sort((a, b) => (b['missed'] as int).compareTo(a['missed'] as int));

  print('\n=== Top 30 Business Logic Files by Uncovered Lines ===\n');
  for (final r in results.take(30)) {
    final pct = (r['pct'] as double).toStringAsFixed(1);
    final fname =
        (r['file'] as String).replaceFirst(RegExp(r'.*/lib/'), 'lib/');
    print('  ${r['missed'].toString().padLeft(4)} missed  $pct%  $fname');
  }
  print('\nTotal files with missing coverage: ${results.length}');
}
