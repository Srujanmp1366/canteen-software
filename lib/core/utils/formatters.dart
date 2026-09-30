import 'package:intl/intl.dart';

import '../../models/raw_material.dart';

String money(num value) => NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
).format(value);
String number(num value) => NumberFormat('#,##0.##', 'en_IN').format(value);
String quantity(num value, UnitType unit) => '${number(value)} ${unit.label}';
String date(DateTime? value) => value == null
    ? 'Not tracked'
    : DateFormat('dd MMM yyyy', 'en_IN').format(value);
String dateTime(DateTime value) =>
    DateFormat('dd MMM · h:mm a', 'en_IN').format(value);
String words(String value) => value
    .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
    .replaceFirstMapped(RegExp(r'^.'), (m) => m[0]!.toUpperCase());
String errorMessage(Object error) => error.toString().replaceFirst(
  RegExp(r'^(Invalid argument\(s\)|Bad state): '),
  '',
);
