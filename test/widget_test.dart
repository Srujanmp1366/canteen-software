import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:canteen_inventory/app/app.dart';
import 'package:canteen_inventory/app/router/app_router.dart';
import 'package:canteen_inventory/features/materials/application/inventory_controller.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en_IN'));
  for (final width in [360.0, 800.0, 1200.0]) {
    testWidgets('Dashboard and navigation fit a $width px viewport', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const ProviderScope(child: CanteenApp()));
      await tester.pumpAndSettle();
      expect(find.text('Your kitchen, in balance.'), findsOneWidget);
      expect(find.text('Total materials'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Inventory').last);
      await tester.pumpAndSettle();
      expect(find.text('Raw Materials'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField).first, 'no such material');
      await tester.pumpAndSettle();
      expect(find.text('No materials found'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Add material and receive stock through the forms', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CanteenApp(),
      ),
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go('/inventory/new');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Basmati Rice');
    await tester.enterText(find.byType(TextFormField).at(1), '10');
    await tester.enterText(find.byType(TextFormField).at(2), '90');
    final save = find.widgetWithText(FilledButton, 'Add Material');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    final data = container.read(inventoryProvider).requireValue;
    final material = data.materials.singleWhere(
      (m) => m.name == 'Basmati Rice',
    );
    expect(material.currentQuantity, 0);
    container.read(routerProvider).go('/inventory/${material.materialId}/add');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '25');
    final receive = find.widgetWithText(FilledButton, 'Add Stock');
    await tester.ensureVisible(receive);
    await tester.tap(receive);
    await tester.pumpAndSettle();
    expect(
      container
          .read(inventoryProvider)
          .requireValue
          .material(material.materialId)
          .currentQuantity,
      25,
    );
    expect(tester.takeException(), isNull);
  });
}
