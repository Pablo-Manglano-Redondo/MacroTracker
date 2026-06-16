import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/settings/presentation/bloc/export_import_bloc.dart';
import 'package:macrotracker/features/settings/domain/usecase/export_data_usecase.dart';
import 'package:macrotracker/features/settings/domain/usecase/import_data_usecase.dart';

void main() {
  late ExportImportBloc bloc;
  late _FakeExportDataUsecase fakeExportDataUsecase;
  late _FakeImportDataUsecase fakeImportDataUsecase;

  setUp(() {
    fakeExportDataUsecase = _FakeExportDataUsecase();
    fakeImportDataUsecase = _FakeImportDataUsecase();
    bloc = ExportImportBloc(fakeExportDataUsecase, fakeImportDataUsecase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is ExportImportInitial', () {
    expect(bloc.state, isA<ExportImportInitial>());
  });

  group('ExportDataEvent', () {
    test('emits ExportImportLoadingState and ExportImportSuccess on success', () async {
      fakeExportDataUsecase.exportResult = 'mock_path.zip';
      
      final states = <ExportImportState>[];
      bloc.stream.listen(states.add);

      bloc.add(ExportDataEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ExportImportLoadingState>(),
        isA<ExportImportSuccess>(),
      ]);
    });

    test('emits ExportImportLoadingState and ExportImportInitial when result is null', () async {
      fakeExportDataUsecase.exportResult = null;
      
      final states = <ExportImportState>[];
      bloc.stream.listen(states.add);

      bloc.add(ExportDataEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ExportImportLoadingState>(),
        isA<ExportImportInitial>(),
      ]);
    });

    test('emits ExportImportLoadingState and ExportImportInitial when result is empty', () async {
      fakeExportDataUsecase.exportResult = '';
      
      final states = <ExportImportState>[];
      bloc.stream.listen(states.add);

      bloc.add(ExportDataEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ExportImportLoadingState>(),
        isA<ExportImportInitial>(),
      ]);
    });

    test('emits ExportImportLoadingState and ExportImportError on exception', () async {
      fakeExportDataUsecase.shouldThrow = true;
      
      final states = <ExportImportState>[];
      bloc.stream.listen(states.add);

      bloc.add(ExportDataEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ExportImportLoadingState>(),
        isA<ExportImportError>(),
      ]);
    });
  });

  group('ImportDataEvent', () {
    test('emits ExportImportLoadingState and ExportImportSuccess on success (true)', () async {
      fakeImportDataUsecase.importResult = true;
      
      final states = <ExportImportState>[];
      bloc.stream.listen(states.add);

      bloc.add(ImportDataEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ExportImportLoadingState>(),
        isA<ExportImportSuccess>(),
      ]);
    });

    test('emits ExportImportLoadingState and ExportImportInitial when result is false', () async {
      fakeImportDataUsecase.importResult = false;
      
      final states = <ExportImportState>[];
      bloc.stream.listen(states.add);

      bloc.add(ImportDataEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ExportImportLoadingState>(),
        isA<ExportImportInitial>(),
      ]);
    });

    test('emits ExportImportLoadingState and ExportImportError on exception', () async {
      fakeImportDataUsecase.shouldThrow = true;
      
      final states = <ExportImportState>[];
      bloc.stream.listen(states.add);

      bloc.add(ImportDataEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ExportImportLoadingState>(),
        isA<ExportImportError>(),
      ]);
    });
  });
}

class _FakeExportDataUsecase implements ExportDataUsecase {
  String? exportResult;
  bool shouldThrow = false;

  @override
  Future<String?> exportData(
    String exportZipFileName,
    String userActivityJsonFileName,
    String userIntakeJsonFileName,
    String trackedDayJsonFileName,
    String recipeJsonFileName,
    String bodyMeasurementJsonFileName,
    String dailyHabitJsonFileName,
    String userJsonFileName,
    String configJsonFileName, {
    String? customOutputPath,
  }) async {
    if (shouldThrow) {
      throw Exception('Failed to export');
    }
    return exportResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeImportDataUsecase implements ImportDataUsecase {
  bool importResult = true;
  bool shouldThrow = false;

  @override
  Future<bool> importData(
    String userActivityJsonFileName,
    String userIntakeJsonFileName,
    String trackedDayJsonFileName,
    String recipeJsonFileName,
    String bodyMeasurementJsonFileName,
    String dailyHabitJsonFileName,
    String userJsonFileName,
    String configJsonFileName,
  ) async {
    if (shouldThrow) {
      throw Exception('Failed to import');
    }
    return importResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
