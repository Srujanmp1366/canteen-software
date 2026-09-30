import '../../models/raw_material.dart';
import '../../models/inventory.dart';
import '../../models/inventory_alert.dart';
import '../../models/stock_batch.dart';
import '../../models/stock_transaction.dart';

class InventorySnapshot {
  InventorySnapshot({
    required List<RawMaterial> materials,
    required List<Inventory> inventory,
    required List<StockBatch> batches,
    required List<StockTransaction> transactions,
    required List<InventoryAlert> alerts,
  }) : materials = List.unmodifiable(materials),
       inventory = List.unmodifiable(inventory),
       batches = List.unmodifiable(batches),
       transactions = List.unmodifiable(transactions),
       alerts = List.unmodifiable(alerts);
  final List<RawMaterial> materials;
  final List<Inventory> inventory;
  final List<StockBatch> batches;
  final List<StockTransaction> transactions;
  final List<InventoryAlert> alerts;
  RawMaterial material(String id) =>
      materials.firstWhere((m) => m.materialId == id);
}

class AddStockRequest {
  const AddStockRequest({
    required this.materialId,
    required this.quantity,
    required this.batchId,
    required this.purchaseDate,
    this.expiryDate,
    required this.purchasePrice,
    this.reference = '',
    this.notes = '',
  });
  final String materialId, batchId, reference, notes;
  final double quantity, purchasePrice;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
}

class RemoveStockRequest {
  const RemoveStockRequest({
    required this.materialId,
    required this.batchId,
    required this.quantity,
    required this.reason,
    this.reference = '',
    this.notes = '',
  });
  final String materialId, batchId, reason, reference, notes;
  final double quantity;
}

abstract class InventoryRepository {
  Future<InventorySnapshot> load();
  Future<void> addMaterial(RawMaterial material);
  Future<void> updateMaterial(RawMaterial material);
  Future<void> addStock(AddStockRequest request);
  Future<void> removeStock(RemoveStockRequest request);
}
