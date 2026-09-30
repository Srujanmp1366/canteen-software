enum TransactionType { stockIn, stockOut, adjustment, transfer }

class StockTransaction {
  const StockTransaction({
    required this.transactionId,
    required this.transactionType,
    required this.materialId,
    required this.batchId,
    required this.quantity,
    required this.transactionDate,
    this.referenceId = '',
    this.referenceType = '',
    this.notes = '',
    this.createdBy = 'Inventory Manager',
  });
  final String transactionId,
      materialId,
      batchId,
      referenceId,
      referenceType,
      notes,
      createdBy;
  final TransactionType transactionType;
  final double quantity;
  final DateTime transactionDate;
}
