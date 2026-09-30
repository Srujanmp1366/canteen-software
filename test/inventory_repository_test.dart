import 'package:flutter_test/flutter_test.dart';
import 'package:canteen_inventory/data/repositories/inventory_repository.dart';
import 'package:canteen_inventory/data/repositories/mock_inventory_repository.dart';
import 'package:canteen_inventory/models/inventory_alert.dart';
import 'package:canteen_inventory/models/stock_batch.dart';
import 'package:canteen_inventory/models/stock_transaction.dart';
import 'package:canteen_inventory/models/purchase_order.dart';
import 'package:canteen_inventory/models/purchase_order_item.dart';

void main() {
  final now = DateTime(2026, 9, 30, 12);
  late MockInventoryRepository repo;
  setUp(() => repo = MockInventoryRepository(clock: () => now));

  test(
    'Seeded batch, material, inventory, and transaction balances reconcile',
    () async {
      final data = await repo.load();
      expect(data.materials.length, 16);
      expect(data.batches.length, greaterThanOrEqualTo(10));
      expect(data.transactions.length, greaterThanOrEqualTo(20));
      expect(data.alerts.length, greaterThanOrEqualTo(5));
      for (final m in data.materials) {
        final batchTotal = data.batches
            .where((b) => b.materialId == m.materialId)
            .fold<double>(0, (sum, b) => sum + b.quantity);
        final movementTotal = data.transactions
            .where((t) => t.materialId == m.materialId)
            .fold<double>(
              0,
              (sum, t) =>
                  sum +
                  (t.transactionType == TransactionType.stockIn
                      ? t.quantity
                      : -t.quantity),
            );
        expect(batchTotal, m.currentQuantity);
        expect(movementTotal, m.currentQuantity);
        expect(
          data.inventory
              .singleWhere((i) => i.materialId == m.materialId)
              .availableQuantity,
          m.currentQuantity,
        );
      }
      expect(() => data.materials.clear(), throwsUnsupportedError);
    },
  );

  test(
    'Rejected stock removal is atomic and never makes stock negative',
    () async {
      final before = await repo.load();
      await expectLater(
        repo.removeStock(
          const RemoveStockRequest(
            materialId: 'MAT-003',
            batchId: 'BAT-103',
            quantity: 9,
            reason: 'Kitchen Consumption',
          ),
        ),
        throwsArgumentError,
      );
      final after = await repo.load();
      expect(after.material('MAT-003').currentQuantity, 8);
      expect(
        after.batches.singleWhere((b) => b.batchId == 'BAT-103').quantity,
        8,
      );
      expect(after.transactions.length, before.transactions.length);
    },
  );

  test(
    'Receiving stock updates balances, writes receipt, and resolves low stock',
    () async {
      await repo.addStock(
        AddStockRequest(
          materialId: 'MAT-003',
          quantity: 10,
          batchId: 'NEW-OIL',
          purchaseDate: now,
          purchasePrice: 125,
        ),
      );
      final data = await repo.load();
      expect(data.material('MAT-003').currentQuantity, 18);
      expect(data.material('MAT-003').isLowStock, isFalse);
      expect(
        data.inventory
            .singleWhere((i) => i.materialId == 'MAT-003')
            .availableQuantity,
        18,
      );
      expect(data.transactions.first.transactionType, TransactionType.stockIn);
      expect(data.transactions.first.quantity, 10);
      expect(
        data.alerts.singleWhere((a) => a.alertId == 'LOW-MAT-003').status,
        AlertStatus.resolved,
      );
      await repo.removeStock(
        const RemoveStockRequest(
          materialId: 'MAT-003',
          batchId: 'NEW-OIL',
          quantity: 10,
          reason: 'Kitchen Consumption',
        ),
      );
      final after = await repo.load();
      expect(
        after.alerts.singleWhere((a) => a.alertId == 'LOW-MAT-003').status,
        AlertStatus.active,
      );
      expect(
        after.batches.singleWhere((b) => b.batchId == 'NEW-OIL').statusAt(now),
        BatchStatus.consumed,
      );
    },
  );

  test('Expiry required, invalid quantity, and batch collision reject without changes', () async {
    final count = (await repo.load()).transactions.length;
    await expectLater(
      repo.addStock(
        AddStockRequest(
          materialId: 'MAT-004',
          quantity: 10,
          batchId: 'MILK',
          purchaseDate: now,
          purchasePrice: 55,
        ),
      ),
      throwsArgumentError,
    );
    await expectLater(
      repo.addStock(
        AddStockRequest(
          materialId: 'MAT-001',
          quantity: double.nan,
          batchId: 'RICE',
          purchaseDate: now,
          purchasePrice: 52,
        ),
      ),
      throwsArgumentError,
    );
    await expectLater(
      repo.addStock(
        AddStockRequest(
          materialId: 'MAT-001',
          quantity: 10,
          batchId: 'BAT-103',
          purchaseDate: now,
          purchasePrice: 52,
        ),
      ),
      throwsArgumentError,
    );
    expect((await repo.load()).transactions.length, count);
  });

  test(
    'Identical batch receipts merge, and consuming uses selected batch limit',
    () async {
      final request = AddStockRequest(
        materialId: 'MAT-001',
        quantity: 5,
        batchId: 'RICE-NEW',
        purchaseDate: now,
        purchasePrice: 52,
      );
      await repo.addStock(request);
      await repo.addStock(request);
      expect(
        (await repo.load()).batches
            .singleWhere((b) => b.batchId == 'RICE-NEW')
            .quantity,
        10,
      );
      await expectLater(
        repo.removeStock(
          const RemoveStockRequest(
            materialId: 'MAT-001',
            batchId: 'RICE-NEW',
            quantity: 11,
            reason: 'Wastage',
          ),
        ),
        throwsArgumentError,
      );
    },
  );

  test('Expired stock cannot be consumed, but can be disposed of', () async {
    await expectLater(
      repo.removeStock(
        const RemoveStockRequest(
          materialId: 'MAT-016',
          batchId: 'BAT-116',
          quantity: 4,
          reason: 'Kitchen Consumption',
        ),
      ),
      throwsArgumentError,
    );
    await repo.removeStock(
      const RemoveStockRequest(
        materialId: 'MAT-016',
        batchId: 'BAT-116',
        quantity: 4,
        reason: 'Wastage',
      ),
    );
    expect((await repo.load()).material('MAT-016').currentQuantity, 0);
  });

  test(
    'Material edits preserve balances and prevent changing historical units',
    () async {
      final material = (await repo.load()).material('MAT-001');
      await repo.updateMaterial(
        material.copyWith(currentQuantity: 999, pricePerUnit: 60),
      );
      expect((await repo.load()).material('MAT-001').currentQuantity, 85);
      expect((await repo.load()).material('MAT-001').stockValue, 5100);
    },
  );

  test('Expiry compares calendar dates and zero quantity is consumed', () {
    StockBatch batch(DateTime expiry, {double quantity = 1}) => StockBatch(
      batchId: 'B',
      materialId: 'M',
      quantity: quantity,
      purchaseDate: now.subtract(const Duration(days: 3)),
      expiryDate: expiry,
      purchasePrice: 10,
    );
    expect(batch(DateTime(2026, 9, 30)).daysRemainingAt(now), 0);
    expect(
      batch(DateTime(2026, 9, 30)).statusAt(now),
      BatchStatus.expiringSoon,
    );
    expect(batch(DateTime(2026, 9, 29)).statusAt(now), BatchStatus.expired);
    expect(batch(DateTime(2026, 10, 8)).statusAt(now), BatchStatus.active);
    expect(
      batch(DateTime(2026, 9, 29), quantity: 0).statusAt(now),
      BatchStatus.consumed,
    );
  });

  test(
    'Purchase total and partial/full receipt status derive from line items',
    () {
      PurchaseOrderItem item(double received) => PurchaseOrderItem(
        orderItemId: 'I',
        orderId: 'P',
        materialId: 'MAT-001',
        quantity: 50,
        unitPrice: 52,
        receivedQuantity: received,
      );
      final order = PurchaseOrder(
        orderId: 'P',
        supplierId: 'S',
        orderDate: now,
        expectedDeliveryDate: now,
        status: PurchaseOrderStatus.pending,
        createdAt: now,
        updatedAt: now,
        items: [item(0)],
      );
      expect(order.totalAmount, 2600);
      expect(
        PurchaseOrder.receivedStatus([item(0)]),
        PurchaseOrderStatus.confirmed,
      );
      expect(
        PurchaseOrder.receivedStatus([item(25)]),
        PurchaseOrderStatus.partiallyDelivered,
      );
      expect(
        PurchaseOrder.receivedStatus([item(50)]),
        PurchaseOrderStatus.delivered,
      );
      expect(
        () => PurchaseOrder.receivedStatus([item(51)]),
        throwsArgumentError,
      );
    },
  );
}
