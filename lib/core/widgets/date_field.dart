import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.required = false,
  });
  final String label;
  final DateTime? value, firstDate, lastDate;
  final ValueChanged<DateTime> onChanged;
  final bool required;
  @override
  Widget build(BuildContext context) => FormField<DateTime>(
    key: ValueKey('$label$value'),
    initialValue: value,
    validator: (_) => required && value == null ? 'Select a date.' : null,
    builder: (field) => InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final start = firstDate ?? DateTime(2000);
        final end = lastDate ?? DateTime.now().add(const Duration(days: 3650));
        var initial = value ?? DateTime.now();
        if (initial.isBefore(start)) initial = start;
        if (initial.isAfter(end)) initial = end;
        final selected = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: start,
          lastDate: end,
        );
        if (selected != null) onChanged(selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: field.errorText,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
        ),
        child: Text(value == null ? 'Select date' : date(value)),
      ),
    ),
  );
}
