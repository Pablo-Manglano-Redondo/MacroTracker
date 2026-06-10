import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';

void main() {
  group('UnitCalc - Length', () {
    test('cmToInches converts correctly', () {
      expect(UnitCalc.cmToInches(2.54), closeTo(1, 0.001));
      expect(UnitCalc.cmToInches(0), 0);
      expect(UnitCalc.cmToInches(180), closeTo(70.866, 0.01));
    });

    test('inchesToCm converts correctly', () {
      expect(UnitCalc.inchesToCm(1), closeTo(2.54, 0.001));
      expect(UnitCalc.inchesToCm(0), 0);
      expect(UnitCalc.inchesToCm(70.866), closeTo(180, 0.1));
    });

    test('cmToFeet converts correctly', () {
      expect(UnitCalc.cmToFeet(30.48), closeTo(1, 0.01));
      expect(UnitCalc.cmToFeet(0), 0);
      expect(UnitCalc.cmToFeet(180), closeTo(5.91, 0.01));
    });

    test('feetToCm converts correctly', () {
      expect(UnitCalc.feetToCm(1), 30.0);
      expect(UnitCalc.feetToCm(0), 0);
    });
  });

  group('UnitCalc - Mass', () {
    test('kgToLbs converts correctly', () {
      expect(UnitCalc.kgToLbs(1), closeTo(2, 0));
      expect(UnitCalc.kgToLbs(80), closeTo(176, 1));
      expect(UnitCalc.kgToLbs(0), 0);
    });

    test('lbsToKg converts correctly', () {
      expect(UnitCalc.lbsToKg(2.20462), closeTo(1, 0.01));
      expect(UnitCalc.lbsToKg(0), 0);
    });

    test('gToOz converts correctly', () {
      expect(UnitCalc.gToOz(28.3495), closeTo(1, 0.001));
      expect(UnitCalc.gToOz(0), 0);
      expect(UnitCalc.gToOz(100), closeTo(3.527, 0.01));
    });

    test('ozToG converts correctly', () {
      expect(UnitCalc.ozToG(1), closeTo(28.3495, 0.001));
      expect(UnitCalc.ozToG(0), 0);
    });
  });

  group('UnitCalc - Volume', () {
    test('mlToFlOz converts correctly', () {
      expect(UnitCalc.mlToFlOz(29.5735), closeTo(1, 0.001));
      expect(UnitCalc.mlToFlOz(0), 0);
      expect(UnitCalc.mlToFlOz(250), closeTo(8.454, 0.01));
    });

    test('flOzToMl converts correctly', () {
      expect(UnitCalc.flOzToMl(1), closeTo(29.5735, 0.001));
      expect(UnitCalc.flOzToMl(0), 0);
    });
  });

  group('UnitCalc - Round-trip', () {
    test('cm -> inches -> cm returns original', () {
      const original = 175.0;
      final result = UnitCalc.inchesToCm(UnitCalc.cmToInches(original));
      expect(result, closeTo(original, 0.1));
    });

    test('kg -> lbs -> kg returns original', () {
      const original = 75.0;
      final result = UnitCalc.lbsToKg(UnitCalc.kgToLbs(original));
      expect(result, closeTo(original, 1));
    });

    test('g -> oz -> g returns original', () {
      const original = 500.0;
      final result = UnitCalc.ozToG(UnitCalc.gToOz(original));
      expect(result, closeTo(original, 0.1));
    });
  });

  group('UnitCalc - metricToImperialValue / imperialToMetricValue', () {
    test('metricToImperialValue converts g to oz', () {
      expect(UnitCalc.metricToImperialValue(28.3495, 'g'), closeTo(1, 0.001));
    });

    test('metricToImperialValue converts ml to fl oz', () {
      expect(UnitCalc.metricToImperialValue(29.5735, 'ml'), closeTo(1, 0.001));
    });

    test('metricToImperialValue returns same for unknown units', () {
      expect(UnitCalc.metricToImperialValue(100, 'unit'), 100);
    });

    test('imperialToMetricValue converts oz to g', () {
      expect(UnitCalc.imperialToMetricValue(1, 'oz'), closeTo(28.3495, 0.001));
    });

    test('imperialToMetricValue returns same for unknown units', () {
      expect(UnitCalc.imperialToMetricValue(100, 'unknown'), 100);
    });
  });
}
