// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('coverage/lcov.info not found. Run "flutter test --coverage" first.');
    return;
  }

  final lines = file.readAsLinesSync();
  int totalLF = 0;
  int totalLH = 0;

  int totalBizLF = 0;
  int totalBizLH = 0;

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
        if (!isGenerated) {
          totalLF += currentLF;
          totalLH += currentLH;

          // Check if it is business logic (not presentation / screen / widget)
          final isBiz = !currentFile.contains('/presentation/') &&
              !currentFile.contains('/widgets/') &&
              !currentFile.endsWith('_screen.dart');
          if (isBiz) {
            totalBizLF += currentLF;
            totalBizLH += currentLH;
          }
        }
      }
    }
  }

  final overallPercent = totalLF == 0 ? 0.0 : (totalLH / totalLF) * 100;
  final bizPercent = totalBizLF == 0 ? 0.0 : (totalBizLH / totalBizLF) * 100;

  print('====================================');
  print('Total Executable Lines (LF): $totalLF');
  print('Total Covered Lines (LH): $totalLH');
  print('Overall Coverage: ${overallPercent.toStringAsFixed(2)}%');
  print('------------------------------------');
  print('Total Business Logic Executable Lines (LF): $totalBizLF');
  print('Total Business Logic Covered Lines (LH): $totalBizLH');
  print('Business Logic Coverage: ${bizPercent.toStringAsFixed(2)}%');
  print('====================================');
}
