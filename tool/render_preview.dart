import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:canteen_inventory/app/app.dart';
import 'package:canteen_inventory/app/router/app_router.dart';

// Run with flutter test tool/render_preview.dart. Outputs are disposable.
void main() {
  const sdkPath = String.fromEnvironment('FLUTTER_SDK', defaultValue: 'C:/src/flutter');
  setUpAll(() => initializeDateFormatting('en_IN'));
  for (final width in [390.0, 1100.0]) {
    testWidgets('Render $width px previews', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        final font = FontLoader('Roboto');
        font.addFont(
          File(
            '$sdkPath/bin/cache/artifacts/material_fonts/roboto-regular.ttf',
          ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
        await font.load();
        final icons = FontLoader('MaterialIcons');
        icons.addFont(File('$sdkPath/bin/cache/artifacts/material_fonts/materialicons-regular.otf')
          .readAsBytes().then((bytes) => ByteData.sublistView(bytes)));
        await icons.load();
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: UncontrolledProviderScope(
            container: container,
            child: const CanteenApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
        await tester.runAsync(() async {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await render.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('build/previews/$name-${width.toInt()}.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('dashboard');
      container.read(routerProvider).go('/inventory');
      await tester.pumpAndSettle();
      await capture('inventory');
      container.read(routerProvider).go('/inventory/MAT-001');
      await tester.pumpAndSettle();
      await capture('material');
      expect(tester.takeException(), isNull);
    });
  }
}
