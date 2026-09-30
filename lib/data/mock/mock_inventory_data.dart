import '../../models/raw_material.dart';
import '../../models/stock_batch.dart';
import '../../models/stock_transaction.dart';
import '../../models/supplier.dart';
import '../../models/purchase_order.dart';
import '../../models/purchase_order_item.dart';

class MockInventoryData {
  MockInventoryData(this.now);
  final DateTime now;
  List<RawMaterial> materials() {
    const rows = <(String, String, UnitType, double, double, double, bool)>[
      ('Rice', 'Grains', UnitType.kg, 85, 30, 52, false),
      ('Wheat Flour', 'Grains', UnitType.kg, 42, 20, 44, false),
      ('Cooking Oil', 'Grocery', UnitType.litre, 8, 15, 125, false),
      ('Milk', 'Dairy', UnitType.litre, 18, 20, 55, true),
      ('Curd', 'Dairy', UnitType.kg, 12, 5, 70, true),
      ('Tomatoes', 'Vegetables', UnitType.kg, 6, 10, 32, true),
      ('Onions', 'Vegetables', UnitType.kg, 36, 15, 28, false),
      ('Potatoes', 'Vegetables', UnitType.kg, 48, 20, 25, false),
      ('Sugar', 'Grocery', UnitType.kg, 22, 10, 45, false),
      ('Salt', 'Spices', UnitType.kg, 9, 3, 20, false),
      ('Tea Powder', 'Beverages', UnitType.kg, 2, 4, 320, false),
      ('Coffee Powder', 'Beverages', UnitType.kg, 5, 2, 480, false),
      ('Bread', 'Bakery', UnitType.packet, 0, 10, 40, true),
      ('Eggs', 'Protein', UnitType.piece, 120, 60, 6, true),
      ('Dal', 'Grains', UnitType.kg, 28, 15, 110, false),
      ('Paneer', 'Dairy', UnitType.kg, 4, 5, 320, true),
    ];
    return [
      for (var i = 0; i < rows.length; i++)
        RawMaterial(
          materialId: 'MAT-${(i + 1).toString().padLeft(3, '0')}',
          name: rows[i].$1,
          category: rows[i].$2,
          unit: rows[i].$3,
          currentQuantity: rows[i].$4,
          reorderLevel: rows[i].$5,
          pricePerUnit: rows[i].$6,
          expiryRequired: rows[i].$7,
          createdAt: now.subtract(const Duration(days: 60)),
          updatedAt: now,
        ),
    ];
  }

  List<StockBatch> batches(List<RawMaterial> materials) => [
    for (var i = 0; i < materials.length; i++)
      StockBatch(
        batchId: 'BAT-${101 + i}',
        materialId: materials[i].materialId,
        quantity: materials[i].currentQuantity,
        purchaseDate: now.subtract(const Duration(days: 3)),
        expiryDate: materials[i].expiryRequired
            ? now.add(
                Duration(
                  days: i == 15
                      ? -1
                      : i == 13
                      ? 12
                      : 2 + i % 3,
                ),
              )
            : null,
        purchasePrice: materials[i].pricePerUnit,
      ),
  ];
  // Each opening receipt minus usage reconciles exactly to its current batch.
  List<StockTransaction> transactions(List<StockBatch> batches) => [
    for (var i = 0; i < batches.length; i++) ...[
      StockTransaction(
        transactionId: 'TXN-${1001 + i * 2}',
        transactionType: TransactionType.stockIn,
        materialId: batches[i].materialId,
        batchId: batches[i].batchId,
        quantity: batches[i].quantity + 2,
        transactionDate: batches[i].purchaseDate,
        referenceId: 'OPENING',
        referenceType: 'Opening stock',
        notes: 'Opening inventory receipt',
      ),
      StockTransaction(
        transactionId: 'TXN-${1002 + i * 2}',
        transactionType: TransactionType.stockOut,
        materialId: batches[i].materialId,
        batchId: batches[i].batchId,
        quantity: 2,
        transactionDate: now.subtract(Duration(hours: i + 1)),
        referenceId: 'KITCHEN',
        referenceType: 'Kitchen Consumption',
      ),
    ],
  ]..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  List<Supplier> suppliers() => [
    for (final (i, name) in [
      'Fresh Farms',
      'Metro Food Supplies',
      'Sri Lakshmi Traders',
      'Daily Dairy Distributors',
      'Campus Wholesale Foods',
    ].indexed)
      Supplier(
        supplierId: 'SUP-${i + 1}',
        supplierName: name,
        contactPerson: [
          'Ravi Kumar',
          'Anita Shah',
          'Lakshmi Rao',
          'Arun Patel',
          'Meera Das',
        ][i],
        phoneNumber: '+91 98765 4321$i',
        email: 'orders${i + 1}@example.com',
        address: '${i + 10}, Market Road, Mysuru',
        isActive: i != 4,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now,
      ),
  ];
  List<PurchaseOrder> orders() => [
    for (var i = 0; i < 8; i++)
      PurchaseOrder(
        orderId: 'PO-2026-${(i + 1).toString().padLeft(4, '0')}',
        supplierId: 'SUP-${i % 5 + 1}',
        orderDate: now.subtract(Duration(days: i + 1)),
        expectedDeliveryDate: now.add(Duration(days: 2 - i)),
        status: PurchaseOrderStatus.values[i % 5],
        createdAt: now,
        updatedAt: now,
        notes: 'Deliver to the canteen receiving area.',
        items: [
          for (var j = 0; j < 2; j++)
            PurchaseOrderItem(
              orderItemId: 'ITEM-$i-$j',
              orderId: 'PO-2026-${(i + 1).toString().padLeft(4, '0')}',
              materialId: j == 0 ? 'MAT-001' : 'MAT-003',
              quantity: j == 0 ? 50 : 30,
              unitPrice: j == 0 ? 52 : 125,
              receivedQuantity: i % 5 == 3
                  ? (j == 0 ? 50 : 30)
                  : i % 5 == 2 && j == 0
                  ? 25
                  : 0,
            ),
        ],
      ),
  ];
}
