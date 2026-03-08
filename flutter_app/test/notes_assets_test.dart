import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notes assets include a sample icon', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final data = await rootBundle.load('assets/images/animals/1_ape_notes.png');
    expect(data.lengthInBytes, greaterThan(0));
  });
}
