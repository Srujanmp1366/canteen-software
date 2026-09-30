import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/async_inventory_view.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_body.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../models/raw_material.dart';
import '../../../models/stock_batch.dart';
import '../application/inventory_controller.dart';

class StockFormScreen extends StatelessWidget {
  const StockFormScreen({
    super.key,
    required this.materialId,
    required this.removing,
  });
  final String materialId;
  final bool removing;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: () => context.canPop() ? context.pop() : context.go('/inventory')),
      title: Text(removing ? 'Remove Stock' : 'Add Stock')),
    body: SafeArea(
      child: AsyncInventoryView(
        builder: (data) {
          final m = data.materials
              .where((m) => m.materialId == materialId)
              .firstOrNull;
          if (m == null) {
            return const EmptyState(
              title: 'Material not found',
              message: 'Select a material from inventory.',
            );
          }
          final batches = data.batches
              .where((b) => b.materialId == materialId && b.quantity > 0)
              .toList();
          if (removing && batches.isEmpty) {
            return const EmptyState(
              title: 'No stock to remove',
              message: 'This material has no remaining stock.',
            );
          }
          return _StockForm(material: m, batches: batches, removing: removing);
        },
      ),
    ),
  );
}

class _StockForm extends ConsumerStatefulWidget {
  const _StockForm({
    required this.material,
    required this.batches,
    required this.removing,
  });
  final RawMaterial material;
  final List<StockBatch> batches;
  final bool removing;
  @override
  ConsumerState<_StockForm> createState() => _StockFormState();
}

class _StockFormState extends ConsumerState<_StockForm> {
  final formKey = GlobalKey<FormState>();
  final amount = TextEditingController();
  final batch = TextEditingController(
    text: 'BAT-${DateTime.now().millisecondsSinceEpoch}',
  );
  late final price = TextEditingController(
    text: '${widget.material.pricePerUnit}',
  );
  final reference = TextEditingController();
  final notes = TextEditingController();
  late String? selectedBatch = widget.batches.firstOrNull?.batchId;
  String reason = 'Kitchen Consumption';
  DateTime purchaseDate = calendarDay(DateTime.now());
  DateTime? expiryDate;
  bool saving = false;
  @override
  void dispose() {
    for (final c in [amount, batch, price, reference, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate() || saving) return;
    setState(() => saving = true);
    try {
      final controller = ref.read(inventoryProvider.notifier);
      if (widget.removing) {
        await controller.removeStock(
          RemoveStockRequest(
            materialId: widget.material.materialId,
            batchId: selectedBatch!,
            quantity: double.parse(amount.text),
            reason: reason,
            reference: reference.text.trim(),
            notes: notes.text.trim(),
          ),
        );
      } else {
        await controller.addStock(
          AddStockRequest(
            materialId: widget.material.materialId,
            quantity: double.parse(amount.text),
            batchId: batch.text.trim(),
            purchaseDate: purchaseDate,
            expiryDate: expiryDate,
            purchasePrice: double.parse(price.text),
            reference: reference.text.trim(),
            notes: notes.text.trim(),
          ),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.removing ? 'Stock removed' : 'Stock added'),
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/inventory/${widget.material.materialId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.material;
    return Form(
      key: formKey,
      child: PageBody(
        children: [
          Text(m.name, style: Theme.of(context).textTheme.headlineMedium),
          Text(
            '${m.materialId} · Current stock: ${quantity(m.currentQuantity, m.unit)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          if (widget.removing) ...[
            DropdownButtonFormField<String>(
              initialValue: selectedBatch,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Batch'),
              items: widget.batches
                  .map(
                    (b) => DropdownMenuItem(
                      value: b.batchId,
                      child: Text(
                        '${b.batchId} · ${quantity(b.quantity, m.unit)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedBatch = v),
              validator: Validators.requiredText,
            ),
            const SizedBox(height: 18),
          ],
          TextFormField(
            controller: amount,
            decoration: InputDecoration(
              labelText: 'Quantity',
              suffixText: m.unit.label,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              final error = Validators.positive(v);
              if (error != null) return error;
              if (widget.removing) {
                final available =
                    widget.batches
                        .where((b) => b.batchId == selectedBatch)
                        .firstOrNull
                        ?.quantity ??
                    0;
                if (double.parse(v!) > available) {
                  return 'Only ${quantity(available, m.unit)} available in this batch.';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          if (!widget.removing) ...[
            TextFormField(
              controller: batch,
              decoration: const InputDecoration(labelText: 'Batch ID'),
              validator: Validators.requiredText,
            ),
            const SizedBox(height: 18),
            DateField(
              label: 'Purchase Date',
              value: purchaseDate,
              lastDate: DateTime.now(),
              required: true,
              onChanged: (v) => setState(() {
                purchaseDate = v;
                if (expiryDate != null && expiryDate!.isBefore(v)) {
                  expiryDate = null;
                }
              }),
            ),
            const SizedBox(height: 18),
            DateField(
              label: m.expiryRequired
                  ? 'Expiry Date *'
                  : 'Expiry Date (optional)',
              value: expiryDate,
              firstDate: purchaseDate,
              required: m.expiryRequired,
              onChanged: (v) => setState(() => expiryDate = v),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: price,
              decoration: const InputDecoration(
                labelText: 'Purchase Price Per Unit',
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: Validators.nonNegative,
            ),
            const SizedBox(height: 18),
          ] else ...[
            DropdownButtonFormField<String>(
              initialValue: reason,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Reason'),
              items: [
                for (final v in [
                  'Kitchen Consumption',
                  'Damaged',
                  'Wastage',
                  'Manual Correction',
                  'Other',
                ])
                  DropdownMenuItem(value: v, child: Text(v)),
              ],
              onChanged: (v) => setState(() => reason = v!),
            ),
            const SizedBox(height: 18),
          ],
          TextFormField(
            controller: reference,
            decoration: const InputDecoration(
              labelText: 'Reference (optional)',
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: saving ? null : save,
            child: Text(
              saving
                  ? 'Saving…'
                  : widget.removing
                  ? 'Remove Stock'
                  : 'Add Stock',
            ),
          ),
        ],
      ),
    );
  }
}
