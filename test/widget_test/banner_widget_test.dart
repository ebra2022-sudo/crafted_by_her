import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crafted_by_her/presentation/reusable_components/banner_widget.dart'; // Adjust this import

void main() {
  testWidgets('BannerWidget adapts to different screen sizes',
      (WidgetTester tester) async {
    final sizesToTest = [
      const Size(320, 640),
      const Size(600, 1024),
      const Size(1080, 1920),
    ];

    for (final size in sizesToTest) {
      tester.binding.window.physicalSizeTestValue = size;
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerWidget(imagePath: 'assets/images/hero_image.png'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ✅ Find the RichText widget
      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsOneWidget);

      final richTextWidget = tester.widget<RichText>(richTextFinder);

      final textSpan = richTextWidget.text as TextSpan;

      // ✅ Check the content of TextSpan
      expect(textSpan.children, isNotNull);
      expect(textSpan.children!.length, greaterThan(0));

      final combinedText =
          textSpan.children!.map((span) => (span as TextSpan).text).join('');

      expect(combinedText, contains('Crafted by Her'));
      expect(combinedText, contains('Loved by You'));
      expect(combinedText, contains('Celebrate handmade creations'));

      // ✅ Image should exist
      expect(find.byType(Image), findsWidgets);

      // ✅ Container should exist
      expect(find.byType(Container), findsWidgets);

      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    }
  });
}
