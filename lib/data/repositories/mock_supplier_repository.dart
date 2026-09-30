import '../../models/supplier.dart';
import '../mock/mock_inventory_data.dart';
import 'supplier_repository.dart';

class MockSupplierRepository implements SupplierRepository {
  MockSupplierRepository(MockInventoryData data)
    : _suppliers = data.suppliers();
  final List<Supplier> _suppliers;
  @override
  Future<List<Supplier>> getSuppliers() async => List.unmodifiable(_suppliers);
}
