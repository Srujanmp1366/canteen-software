import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/async_inventory_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_body.dart';
import '../../../models/raw_material.dart';
import '../application/inventory_controller.dart';

class MaterialFormScreen extends StatelessWidget {
  const MaterialFormScreen({super.key, this.materialId});
  final String? materialId;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: () => context.canPop() ? context.pop() : context.go('/inventory')),
      title: Text(materialId == null ? 'Add Material' : 'Edit Material'),
    ),
    body: SafeArea(
      child: AsyncInventoryView(
        builder: (data) {
          final matches = data.materials.where(
            (m) => m.materialId == materialId,
          );
          if (materialId != null && matches.isEmpty) {
            return const EmptyState(
              title: 'Material not found',
              message: 'Return to inventory and select a material.',
            );
          }
          return _MaterialForm(
            material: matches.firstOrNull,
            hasHistory: data.batches.any((b) => b.materialId == materialId),
          );
        },
      ),
    ),
  );
}

class _MaterialForm extends ConsumerStatefulWidget {
  const _MaterialForm({this.material, required this.hasHistory});
  final RawMaterial? material;
  final bool hasHistory;
  @override
  ConsumerState<_MaterialForm> createState() => _MaterialFormState();
}

class _MaterialFormState extends ConsumerState<_MaterialForm> {
  final formKey = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.material?.name);
  late final reorder = TextEditingController(
    text: '${widget.material?.reorderLevel ?? 0}',
  );
  late final price = TextEditingController(
    text: '${widget.material?.pricePerUnit ?? 0}',
  );
  late String category = widget.material?.category ?? materialCategories.first;
  late UnitType unit = widget.material?.unit ?? UnitType.kg;
  late bool expiry = widget.material?.expiryRequired ?? false;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    reorder.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate() || saving) return;
    setState(() => saving = true);
    final now = DateTime.now();
    final old = widget.material;
    final material = RawMaterial(
      materialId: old?.materialId ?? 'MAT-${now.microsecondsSinceEpoch}',
      name: name.text.trim(),
      category: category,
      unit: unit,
      reorderLevel: double.parse(reorder.text),
      currentQuantity: old?.currentQuantity ?? 0,
      pricePerUnit: double.parse(price.text),
      expiryRequired: expiry,
      isActive: old?.isActive ?? true,
      createdAt: old?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      await ref
          .read(inventoryProvider.notifier)
          .saveMaterial(material, isNew: old == null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(old == null ? 'Material added' : 'Material updated'),
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/inventory/${material.materialId}');
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
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: PageBody(
      children: [
        Text(
          widget.material == null
              ? 'Make room for a new ingredient.'
              : 'Keep your inventory details up to date.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Material Name'),
          textCapitalization: TextCapitalization.words,
          validator: Validators.requiredText,
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          initialValue: category,
          decoration: const InputDecoration(labelText: 'Category'),
          items: materialCategories
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (v) => setState(() => category = v!),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<UnitType>(
          initialValue: unit,
          decoration: InputDecoration(
            labelText: 'Unit',
            helperText: widget.hasHistory
                ? 'Unit is fixed once stock history exists.'
                : null,
          ),
          items: UnitType.values
              .map((v) => DropdownMenuItem(value: v, child: Text(v.label)))
              .toList(),
          onChanged: widget.hasHistory
              ? null
              : (v) => setState(() => unit = v!),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: reorder,
          decoration: const InputDecoration(labelText: 'Reorder Level'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: Validators.nonNegative,
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: price,
          decoration: const InputDecoration(
            labelText: 'Price Per Unit',
            prefixText: '₹ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: Validators.nonNegative,
        ),
        const SizedBox(height: 14),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Track expiry dates'),
          subtitle: const Text('Require an expiry date for incoming stock.'),
          value: expiry,
          onChanged: (v) => setState(() => expiry = v),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: saving ? null : save,
          child: Text(
            saving
                ? 'Saving…'
                : widget.material == null
                ? 'Add Material'
                : 'Save changes',
          ),
        ),
      ],
    ),
  );
}
