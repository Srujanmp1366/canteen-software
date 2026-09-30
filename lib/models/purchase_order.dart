import 'purchase_order_item.dart';

enum PurchaseOrderStatus {
  pending,
  confirmed,
  partiallyDelivered,
  delivered,
  cancelled,
}

class PurchaseOrder {
  PurchaseOrder({
    required this.orderId,
    required this.supplierId,
    required this.orderDate,
    required this.expectedDeliveryDate,
    required this.status,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    required List<PurchaseOrderItem> items,
  }) : items = List.unmodifiable(items);
  final String orderId, supplierId, notes;
  final DateTime orderDate, expectedDeliveryDate, createdAt, updatedAt;
  final PurchaseOrderStatus status;
  final List<PurchaseOrderItem> items;
  double get totalAmount =>
      items.fold(0, (total, item) => total + item.subTotal);
  static PurchaseOrderStatus receivedStatus(List<PurchaseOrderItem> items) {
    if (items.isEmpty) throw ArgumentError('An order needs at least one item.');
    if (items.any(
      (i) =>
          !i.quantity.isFinite ||
          i.quantity <= 0 ||
          !i.receivedQuantity.isFinite ||
          i.receivedQuantity < 0 ||
          i.receivedQuantity > i.quantity,
    )) {
      throw ArgumentError('Received quantity must be within ordered quantity.');
    }
    if (items.every((i) => i.remainingQuantity == 0)) {
      return PurchaseOrderStatus.delivered;
    }
    if (items.any((i) => i.receivedQuantity > 0)) {
      return PurchaseOrderStatus.partiallyDelivered;
    }
    return PurchaseOrderStatus.confirmed;
  }
}
