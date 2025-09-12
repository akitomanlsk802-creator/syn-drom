import 'package:flutter_test/flutter_test.dart';
import 'package:office_syndrome_helper/data/treatments_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('treatments count must be 19', () {
    expect(treatmentsData.length, equals(19));
  });
}
