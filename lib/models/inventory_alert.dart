enum AlertType { lowStock, expirySoon, expired, reorder }

enum AlertStatus { active, resolved, ignored }

class InventoryAlert {
  const InventoryAlert({
    required this.alertId,
    required this.materialId,
    required this.alertType,
    required this.thresholdQuantity,
    required this.currentQuantity,
    required this.message,
    this.status = AlertStatus.active,
    required this.createdAt,
    this.resolvedAt,
  });
  final String alertId, materialId, message;
  final AlertType alertType;
  final double thresholdQuantity, currentQuantity;
  final AlertStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  InventoryAlert withStatus(AlertStatus value, DateTime now) => InventoryAlert(
    alertId: alertId,
    materialId: materialId,
    alertType: alertType,
    thresholdQuantity: thresholdQuantity,
    currentQuantity: currentQuantity,
    message: message,
    status: value,
    createdAt: createdAt,
    resolvedAt: value == AlertStatus.resolved ? now : null,
  );
}
