import 'package:flutter_test/flutter_test.dart';
import 'package:panel_surya/core/utils/sensor_formatter.dart';

void main() {
  group('SensorFormatter Test Suite', () {
    test('0.0012345 should format to 0.001', () {
      expect(SensorFormatter.format(0.0012345), equals('0.001'));
    });

    test('0.2189456 should format to 0.218', () {
      expect(SensorFormatter.format(0.2189456), equals('0.218'));
    });

    test('31 should format to 31', () {
      expect(SensorFormatter.format(31), equals('31'));
    });

    test('12.5 should format to 12.5', () {
      expect(SensorFormatter.format(12.5), equals('12.5'));
    });

    test('15.123987 should format to 15.123', () {
      expect(SensorFormatter.format(15.123987), equals('15.123'));
    });

    test('30.999999 should format to 30.999', () {
      expect(SensorFormatter.format(30.999999), equals('30.999'));
    });

    test('2.000000 should format to 2', () {
      expect(SensorFormatter.format(2.000000), equals('2'));
    });

    test('null should format to default fallback --', () {
      expect(SensorFormatter.format(null), equals('--'));
    });
  });
}
