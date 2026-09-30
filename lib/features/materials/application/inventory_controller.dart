import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/mock/mock_inventory_data.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../data/repositories/mock_inventory_repository.dart';
import '../../../data/repositories/mock_supplier_repository.dart';
import '../../../data/repositories/mock_purchase_order_repository.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../data/repositories/purchase_order_repository.dart';
import '../../../models/raw_material.dart';
import '../../../models/supplier.dart';
import '../../../models/purchase_order.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => MockInventoryRepository(),
);
final supplierRepositoryProvider = Provider<SupplierRepository>(
  (ref) => MockSupplierRepository(MockInventoryData(DateTime.now())),
);
final purchaseOrderRepositoryProvider = Provider<PurchaseOrderRepository>(
  (ref) => MockPurchaseOrderRepository(MockInventoryData(DateTime.now())),
);
final suppliersProvider = FutureProvider<List<Supplier>>(
  (ref) => ref.watch(supplierRepositoryProvider).getSuppliers(),
);
final ordersProvider = FutureProvider<List<PurchaseOrder>>(
  (ref) => ref.watch(purchaseOrderRepositoryProvider).getOrders(),
);
final inventoryProvider =
    AsyncNotifierProvider<InventoryController, InventorySnapshot>(
      InventoryController.new,
    );

class InventoryController extends AsyncNotifier<InventorySnapshot> {
  @override
  Future<InventorySnapshot> build() =>
      ref.watch(inventoryRepositoryProvider).load();
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(inventoryRepositoryProvider).load(),
    );
  }

  Future<void> _run(Future<void> Function(InventoryRepository) command) async {
    final repository = ref.read(inventoryRepositoryProvider);
    await command(repository);
    // Keep the last good snapshot visible if a command is rejected.
    state = AsyncData(await repository.load());
  }

  Future<void> saveMaterial(RawMaterial m, {required bool isNew}) =>
      _run((r) => isNew ? r.addMaterial(m) : r.updateMaterial(m));
  Future<void> addStock(AddStockRequest r) =>
      _run((repository) => repository.addStock(r));
  Future<void> removeStock(RemoveStockRequest r) =>
      _run((repository) => repository.removeStock(r));
}
