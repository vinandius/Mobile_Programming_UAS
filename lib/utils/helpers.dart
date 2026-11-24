import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

String formatRupiah(int number) {
  NumberFormat rupiah = NumberFormat.currency(locale: 'id', symbol: 'Rp');
  return rupiah.format(number);
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
