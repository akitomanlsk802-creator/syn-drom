import 'package:flutter_test/flutter_test.dart';
import 'package:office_syndrome_helper/main.dart';

void main() {
  testWidgets('Sample widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
  });
}
