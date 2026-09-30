import '../../models/purchase_order.dart';
import '../mock/mock_inventory_data.dart';
import 'purchase_order_repository.dart';

class MockPurchaseOrderRepository implements PurchaseOrderRepository {
  MockPurchaseOrderRepository(MockInventoryData data) : _orders = data.orders();
  final List<PurchaseOrder> _orders;
  @override
  Future<List<PurchaseOrder>> getOrders() async => List.unmodifiable(_orders);
}
