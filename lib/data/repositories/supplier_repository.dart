import '../../models/supplier.dart';

abstract class SupplierRepository {
  Future<List<Supplier>> getSuppliers();
}
