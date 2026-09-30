class PurchaseOrderItem {
  const PurchaseOrderItem({
    required this.orderItemId,
    required this.orderId,
    required this.materialId,
    required this.quantity,
    required this.unitPrice,
    this.receivedQuantity = 0,
  });
  final String orderItemId, orderId, materialId;
  final double quantity, unitPrice, receivedQuantity;
  double get subTotal => quantity * unitPrice;
  double get remainingQuantity => quantity - receivedQuantity;
}
