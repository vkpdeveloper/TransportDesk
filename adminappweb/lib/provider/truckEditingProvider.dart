import 'package:flutter/material.dart';

class TruckEditingProvider with ChangeNotifier {
  List<String> _trucksCategory = [
    "Mini (< 1 MT)",
    "Small (< 5 MT)",
    "Medium (5 - 15 MT)",
    "Large (15 - 40 MT)"
  ];
  String _selectedCategory;

  TruckEditingProvider() {
    _selectedCategory = "Mini (< 1 MT)";
  }

  List<String> get getAllCategories => _trucksCategory;

  String get getSelectedCategoty => _selectedCategory;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
