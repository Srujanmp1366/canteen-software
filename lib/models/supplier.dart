class Supplier {
  const Supplier({
    required this.supplierId,
    required this.supplierName,
    required this.contactPerson,
    required this.phoneNumber,
    this.email = '',
    this.address = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
  final String supplierId,
      supplierName,
      contactPerson,
      phoneNumber,
      email,
      address;
  final bool isActive;
  final DateTime createdAt, updatedAt;
}
