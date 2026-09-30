import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../models/purchase_order.dart';

class OrderPreview extends StatelessWidget {
  const OrderPreview({
    super.key,
    required this.order,
    required this.supplierName,
  });
  final PurchaseOrder order;
  final String supplierName;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(supplierName, style: Theme.of(context).textTheme.titleMedium),
        Text(
          '${order.orderId} · ${order.items.length} items',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              money(order.totalAmount),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            StatusBadge(
              words(order.status.name),
              tone: switch (order.status) {
                PurchaseOrderStatus.pending ||
                PurchaseOrderStatus.partiallyDelivered => StatusTone.orange,
                PurchaseOrderStatus.confirmed => StatusTone.blue,
                PurchaseOrderStatus.cancelled => StatusTone.red,
                _ => StatusTone.green,
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Expected ${date(order.expectedDeliveryDate)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
