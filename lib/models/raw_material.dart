enum UnitType {
  kg('KG'),
  gram('GRAM'),
  litre('L'),
  ml('ML'),
  piece('PIECE'),
  packet('PACKET'),
  box('BOX');

  const UnitType(this.label);
  final String label;
}

const materialCategories = [
  'Grains',
  'Dairy',
  'Vegetables',
  'Grocery',
  'Beverages',
  'Bakery',
  'Protein',
  'Spices',
];

class RawMaterial {
  const RawMaterial({
    required this.materialId,
    required this.name,
    required this.category,
    required this.unit,
    required this.reorderLevel,
    required this.currentQuantity,
    required this.pricePerUnit,
    required this.expiryRequired,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
  final String materialId, name, category;
  final UnitType unit;
  final double reorderLevel, currentQuantity, pricePerUnit;
  final bool expiryRequired, isActive;
  final DateTime createdAt, updatedAt;
  bool get isLowStock => currentQuantity <= reorderLevel;
  bool get isOutOfStock => currentQuantity <= 0;
  double get stockValue => currentQuantity * pricePerUnit;
  String get stockLabel => !isActive
      ? 'Inactive'
      : isOutOfStock
      ? 'Out of stock'
      : isLowStock
      ? 'Low stock'
      : 'In stock';
  RawMaterial copyWith({
    String? name,
    String? category,
    UnitType? unit,
    double? reorderLevel,
    double? currentQuantity,
    double? pricePerUnit,
    bool? expiryRequired,
    bool? isActive,
    DateTime? updatedAt,
  }) => RawMaterial(
    materialId: materialId,
    name: name ?? this.name,
    category: category ?? this.category,
    unit: unit ?? this.unit,
    reorderLevel: reorderLevel ?? this.reorderLevel,
    currentQuantity: currentQuantity ?? this.currentQuantity,
    pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    expiryRequired: expiryRequired ?? this.expiryRequired,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
