import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../models/raw_material.dart';
import '../../../../models/stock_batch.dart';
import '../../../../models/stock_transaction.dart';

class BatchRow extends StatelessWidget {
  const BatchRow({super.key, required this.batch, required this.material});
  final StockBatch batch;
  final RawMaterial material;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              '${material.name} · ${batch.batchId}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            StatusBadge(
              words(batch.status.name),
              tone: switch (batch.status) {
                BatchStatus.expired => StatusTone.red,
                BatchStatus.expiringSoon => StatusTone.orange,
                BatchStatus.consumed => StatusTone.neutral,
                _ => StatusTone.green,
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${quantity(batch.quantity, material.unit)} · ${money(batch.purchasePrice)} / ${material.unit.label}',
        ),
        Text(
          'Purchased ${date(batch.purchaseDate)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          'Expiry: ${date(batch.expiryDate)}${batch.remainingDays == null ? '' : ' · ${batch.remainingDays! < 0 ? '${-batch.remainingDays!} days overdue' : '${batch.remainingDays} days left'}'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
    required this.material,
  });
  final StockTransaction transaction;
  final RawMaterial material;
  @override
  Widget build(BuildContext context) {
    final incoming = transaction.transactionType == TransactionType.stockIn;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: incoming
                ? AppColors.blueSoft
                : AppColors.orangeSoft,
            child: Icon(
              incoming ? Icons.south_west : Icons.north_east,
              color: incoming ? AppColors.blue : AppColors.orange,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${words(transaction.transactionType.name)} · ${transaction.batchId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  transaction.referenceId.isEmpty
                      ? transaction.referenceType
                      : transaction.referenceId,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  dateTime(transaction.transactionDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${incoming ? '+' : '−'}${quantity(transaction.quantity, material.unit)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: incoming ? AppColors.blue : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
