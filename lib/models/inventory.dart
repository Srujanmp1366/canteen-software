class Inventory {
  const Inventory({
    required this.inventoryId,
    required this.materialId,
    required this.totalQuantity,
    required this.availableQuantity,
    this.reservedQuantity = 0,
    required this.lastUpdated,
  });
  final String inventoryId, materialId;
  final double totalQuantity, availableQuantity, reservedQuantity;
  final DateTime lastUpdated;
}
