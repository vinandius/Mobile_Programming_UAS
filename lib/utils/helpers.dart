import 'package:flutter/material.dart';

const incomeColor = Color(0xFF43A047);
const expenseColor = Color(0xFFE53935);
const transferColor = Color(0xFF1E88E5);

const monthsName = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'June',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Des',
];

const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String formatRupiah(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - 1) % 3 == 0) buf.write(".");
    buf.write(digits[i]);
  }
  return '${negative ? "-" : ''}Rp$buf';
}

String formatCompact(int value) {
  if (value >= 1000000) {
    final m = value / 1000000;
    return '${m.toStringAsFixed(m % 1 == 0 ? 0 : 1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).round()}K';
  }
  return '$value';
}
