import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notes assets include a sample icon', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final data = await rootBundle.load('assets/images/animals/notes/16/1_ape.png');
    expect(data.lengthInBytes, greaterThan(0));
  });
}
