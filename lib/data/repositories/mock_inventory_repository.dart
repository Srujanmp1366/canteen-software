import '../../models/raw_material.dart';
import '../../models/inventory.dart';
import '../../models/inventory_alert.dart';
import '../../models/stock_batch.dart';
import '../../models/stock_transaction.dart';
import '../mock/mock_inventory_data.dart';
import 'inventory_repository.dart';

class MockInventoryRepository implements InventoryRepository {
  MockInventoryRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    final seed = MockInventoryData(_clock());
    _materials = seed.materials();
    _batches = seed.batches(_materials);
    _transactions = seed.transactions(_batches);
    _recalculateAlerts();
  }
  final DateTime Function() _clock;
  late final List<RawMaterial> _materials;
  late final List<StockBatch> _batches;
  late final List<StockTransaction> _transactions;
  final List<InventoryAlert> _alerts = [];
  int _sequence = 2000;
  int get expiryWarningDays => 7;

  @override
  Future<InventorySnapshot> load() async {
    _recalculateAlerts();
    return InventorySnapshot(
      materials: _materials,
      batches: _batches,
      transactions: _transactions,
      alerts: _alerts,
      inventory: [
        for (final m in _materials)
          Inventory(
            inventoryId: 'INV-${m.materialId}',
            materialId: m.materialId,
            totalQuantity: m.currentQuantity,
            availableQuantity: m.currentQuantity,
            lastUpdated: m.updatedAt,
          ),
      ],
    );
  }

  RawMaterial _material(String id) => _materials.firstWhere(
    (m) => m.materialId == id,
    orElse: () => throw StateError('Material not found.'),
  );
  void _validateMaterial(RawMaterial m) {
    if (m.name.trim().isEmpty || m.category.trim().isEmpty) {
      throw ArgumentError('Name and category are required.');
    }
    if (!m.reorderLevel.isFinite ||
        m.reorderLevel < 0 ||
        !m.pricePerUnit.isFinite ||
        m.pricePerUnit < 0) {
      throw ArgumentError(
        'Price and reorder level must be non-negative numbers.',
      );
    }
    if (_materials.any(
      (other) =>
          other.materialId != m.materialId &&
          other.name.toLowerCase() == m.name.trim().toLowerCase(),
    )) {
      throw ArgumentError('A material with that name already exists.');
    }
  }

  @override
  Future<void> addMaterial(RawMaterial material) async {
    _validateMaterial(material);
    if (_materials.any((m) => m.materialId == material.materialId)) {
      throw ArgumentError('Material ID already exists.');
    }
    if (material.currentQuantity != 0) {
      throw ArgumentError('Add opening stock using Add Stock.');
    }
    _materials.add(
      material.copyWith(name: material.name.trim(), updatedAt: _clock()),
    );
    _recalculateAlerts();
  }

  @override
  Future<void> updateMaterial(RawMaterial material) async {
    _validateMaterial(material);
    final old = _material(material.materialId);
    if (old.unit != material.unit &&
        _batches.any((b) => b.materialId == old.materialId)) {
      throw ArgumentError('Unit cannot change once stock history exists.');
    }
    if (!old.expiryRequired &&
        material.expiryRequired &&
        _batches.any(
          (b) =>
              b.materialId == old.materialId &&
              b.quantity > 0 &&
              b.expiryDate == null,
        )) {
      throw ArgumentError(
        'Existing stock has no expiry date. Empty these batches before enabling expiry tracking.',
      );
    }
    _materials[_materials.indexOf(old)] = material.copyWith(
      name: material.name.trim(),
      currentQuantity: old.currentQuantity,
      updatedAt: _clock(),
    );
    _recalculateAlerts();
  }

  void _checkQuantity(double quantity) {
    if (!quantity.isFinite || quantity <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }
  }

  @override
  Future<void> addStock(AddStockRequest r) async {
    _checkQuantity(r.quantity);
    final material = _material(r.materialId);
    if (!material.isActive) {
      throw StateError('Activate this material before adding stock.');
    }
    if (r.batchId.trim().isEmpty) throw ArgumentError('Batch ID is required.');
    if (!r.purchasePrice.isFinite || r.purchasePrice < 0) {
      throw ArgumentError('Purchase price must be non-negative.');
    }
    if (calendarDay(r.purchaseDate).isAfter(calendarDay(_clock()))) {
      throw ArgumentError('Purchase date cannot be in the future.');
    }
    if (material.expiryRequired && r.expiryDate == null) {
      throw ArgumentError('Expiry date is required.');
    }
    if (r.expiryDate != null &&
        calendarDay(r.expiryDate!).isBefore(calendarDay(r.purchaseDate))) {
      throw ArgumentError('Expiry date cannot precede purchase date.');
    }
    final id = r.batchId.trim();
    final index = _batches.indexWhere((b) => b.batchId == id);
    if (index >= 0) {
      final b = _batches[index];
      if (b.materialId != r.materialId ||
          b.purchasePrice != r.purchasePrice ||
          calendarDay(b.purchaseDate) != calendarDay(r.purchaseDate) ||
          (b.expiryDate == null ? null : calendarDay(b.expiryDate!)) !=
              (r.expiryDate == null ? null : calendarDay(r.expiryDate!))) {
        throw ArgumentError(
          'This batch exists with different details. Use a new batch ID.',
        );
      }
    }
    // All validation precedes mutation, so a rejected command has no side effects.
    if (index >= 0) {
      _batches[index] = _batches[index].withQuantity(
        _batches[index].quantity + r.quantity,
      );
    } else {
      _batches.add(
        StockBatch(
          batchId: id,
          materialId: r.materialId,
          quantity: r.quantity,
          purchaseDate: r.purchaseDate,
          expiryDate: r.expiryDate,
          purchasePrice: r.purchasePrice,
        ),
      );
    }
    _changeQuantity(material, r.quantity);
    _record(
      material.materialId,
      id,
      r.quantity,
      TransactionType.stockIn,
      r.reference,
      'Manual receipt',
      r.notes,
    );
    _recalculateAlerts();
  }

  @override
  Future<void> removeStock(RemoveStockRequest r) async {
    _checkQuantity(r.quantity);
    final material = _material(r.materialId);
    if (r.reason.trim().isEmpty) throw ArgumentError('Select a reason.');
    final index = _batches.indexWhere(
      (b) => b.batchId == r.batchId && b.materialId == r.materialId,
    );
    if (index < 0) throw ArgumentError('Select a batch for this material.');
    final batch = _batches[index];
    if (r.quantity > material.currentQuantity || r.quantity > batch.quantity) {
      throw ArgumentError('Quantity exceeds available stock in this batch.');
    }
    if (batch.statusAt(_clock()) == BatchStatus.expired &&
        r.reason == 'Kitchen Consumption') {
      throw ArgumentError(
        'Expired stock can only be removed for disposal or correction.',
      );
    }
    _batches[index] = batch.withQuantity(batch.quantity - r.quantity);
    _changeQuantity(material, -r.quantity);
    _record(
      material.materialId,
      r.batchId,
      r.quantity,
      TransactionType.stockOut,
      r.reference,
      r.reason,
      r.notes,
    );
    _recalculateAlerts();
  }

  void _changeQuantity(RawMaterial material, double delta) {
    _materials[_materials.indexOf(material)] = material.copyWith(
      currentQuantity: material.currentQuantity + delta,
      updatedAt: _clock(),
    );
  }

  void _record(
    String material,
    String batch,
    double quantity,
    TransactionType type,
    String reference,
    String reason,
    String notes,
  ) {
    _transactions.insert(
      0,
      StockTransaction(
        transactionId: 'TXN-${++_sequence}',
        transactionType: type,
        materialId: material,
        batchId: batch,
        quantity: quantity,
        transactionDate: _clock(),
        referenceId: reference,
        referenceType: reason,
        notes: notes,
      ),
    );
  }

  void _recalculateAlerts() {
    final current = <InventoryAlert>[];
    final now = _clock();
    for (final m in _materials.where((m) => m.isActive && m.isLowStock)) {
      current.add(
        InventoryAlert(
          alertId: 'LOW-${m.materialId}',
          materialId: m.materialId,
          alertType: AlertType.lowStock,
          thresholdQuantity: m.reorderLevel,
          currentQuantity: m.currentQuantity,
          message: '${m.name} is at or below its reorder level.',
          createdAt: now,
        ),
      );
    }
    for (final b in _batches.where((b) => b.quantity > 0)) {
      final status = b.statusAt(now, warningDays: expiryWarningDays);
      if (status != BatchStatus.expired && status != BatchStatus.expiringSoon) {
        continue;
      }
      final m = _material(b.materialId);
      current.add(
        InventoryAlert(
          alertId: '${status.name}-${b.batchId}',
          materialId: m.materialId,
          alertType: status == BatchStatus.expired
              ? AlertType.expired
              : AlertType.expirySoon,
          thresholdQuantity: 0,
          currentQuantity: b.quantity,
          message:
              '${m.name} · ${b.batchId} ${status == BatchStatus.expired ? 'has expired' : 'expires soon'}.',
          createdAt: now,
        ),
      );
    }
    final keys = current.map((a) => a.alertId).toSet();
    for (var i = 0; i < _alerts.length; i++) {
      if (_alerts[i].status == AlertStatus.active &&
          !keys.contains(_alerts[i].alertId)) {
        _alerts[i] = _alerts[i].withStatus(AlertStatus.resolved, now);
      }
    }
    for (final a in current) {
      final i = _alerts.indexWhere((old) => old.alertId == a.alertId);
      if (i < 0) {
        _alerts.add(a);
        continue;
      }
      final old = _alerts[i];
      _alerts[i] = InventoryAlert(
        alertId: a.alertId,
        materialId: a.materialId,
        alertType: a.alertType,
        thresholdQuantity: a.thresholdQuantity,
        currentQuantity: a.currentQuantity,
        message: a.message,
        createdAt: old.status == AlertStatus.resolved ? now : old.createdAt,
        status: old.status == AlertStatus.ignored
            ? AlertStatus.ignored
            : AlertStatus.active,
      );
    }
  }
}
