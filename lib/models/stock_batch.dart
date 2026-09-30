enum BatchStatus { active, expiringSoon, expired, consumed }

DateTime calendarDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

class StockBatch {
  const StockBatch({
    required this.batchId,
    required this.materialId,
    required this.quantity,
    required this.purchaseDate,
    this.expiryDate,
    required this.purchasePrice,
  });
  final String batchId, materialId;
  final double quantity, purchasePrice;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  int? daysRemainingAt(DateTime now) => expiryDate == null
      ? null
      : calendarDay(expiryDate!).difference(calendarDay(now)).inDays;
  int? get remainingDays => daysRemainingAt(DateTime.now());
  bool get isExpired => status == BatchStatus.expired;
  BatchStatus get status => statusAt(DateTime.now());
  BatchStatus statusAt(DateTime now, {int warningDays = 7}) {
    if (quantity <= 0) return BatchStatus.consumed;
    final days = daysRemainingAt(now);
    if (days == null) return BatchStatus.active;
    if (days < 0) return BatchStatus.expired;
    return days <= warningDays ? BatchStatus.expiringSoon : BatchStatus.active;
  }

  StockBatch withQuantity(double value) => StockBatch(
    batchId: batchId,
    materialId: materialId,
    quantity: value,
    purchaseDate: purchaseDate,
    expiryDate: expiryDate,
    purchasePrice: purchasePrice,
  );
}
