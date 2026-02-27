import 'package:flutter_test/flutter_test.dart';
import 'package:musuem_image_saver/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MuseumApp());
    await tester.pumpAndSettle();

    expect(find.text('Museum Profiles'), findsOneWidget);
  });
}
