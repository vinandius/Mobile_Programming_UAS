import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  const CategoryItem(this.name, this.icon);
}

const expenseCategories = [
  CategoryItem('Food', Icons.restaurant),
  CategoryItem('Transport', Icons.directions_bus),
  CategoryItem('Shopping', Icons.shopping_bag),
  CategoryItem('Bills', Icons.receipt_long),
  CategoryItem('Health', Icons.local_hospital),
  CategoryItem('Entertainment', Icons.movie),
  CategoryItem('Education', Icons.school),
  CategoryItem('Other', Icons.more_horiz),
];

const incomeCategories = [
  CategoryItem('Salary', Icons.payments),
  CategoryItem('Allowance', Icons.account_balance_wallet),
  CategoryItem('Bonus', Icons.card_giftcard),
  CategoryItem('Investment', Icons.trending_up),
  CategoryItem('Other', Icons.more_horiz),
];
