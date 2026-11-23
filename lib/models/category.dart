import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  const CategoryItem(this.name, this.icon);
}

const expenseCategories = [
  CategoryItem('Food', Icons.food_bank),
  CategoryItem('Social Life', Icons.social_distance),
  CategoryItem('Pets', Icons.pets),
  CategoryItem('Transport', Icons.directions_bus),
  CategoryItem('Culture', Icons.image),
  CategoryItem('Household', Icons.chair),
  CategoryItem('Apparel', Icons.checkroom),
  CategoryItem('Beauty', Icons.face),
  CategoryItem('Health', Icons.health_and_safety),
  CategoryItem('Education', Icons.school),
  CategoryItem('Gift', Icons.card_giftcard_sharp),
  CategoryItem('Other', Icons.more_horiz),
];

const incomeCategories = [
  CategoryItem('Allowance', Icons.account_balance_wallet),
  CategoryItem('Salary', Icons.payments),
  CategoryItem('Petty Cash', Icons.money),
  CategoryItem('Bonus', Icons.card_giftcard),
  CategoryItem('Other', Icons.more_horiz),
];
