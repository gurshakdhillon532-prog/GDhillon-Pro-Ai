import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/clipboard_item.dart';

class SearchProvider extends ChangeNotifier {
  List<ClipboardItem> _allItems = [];
  List<ClipboardItem> _filteredItems = [];
  String _searchQuery = '';
  bool _isSearching = false;
  String _selectedCategory = 'All';

  List<ClipboardItem> get filteredItems => _filteredItems;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => ['All', 'Text', 'URL', 'Code', 'Favorites'];

  Future<void> loadItems() async {
    _allItems = await DatabaseService.instance.getAllItems();
    _filteredItems = List.from(_allItems);
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    
    _filteredItems = _allItems.where((item) {
      final matchesSearch = item.content.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || 
          _selectedCategory == 'Favorites' && item.isFavorite ||
          _getCategory(item.content) == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
    
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    
    _filteredItems = _allItems.where((item) {
      if (category == 'All') return true;
      if (category == 'Favorites') return item.isFavorite;
      return _getCategory(item.content) == category;
    }).toList();
    
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    _selectedCategory = 'All';
    _filteredItems = List.from(_allItems);
    notifyListeners();
  }

  String _getCategory(String content) {
    if (content.contains('http')) return 'URL';
    if (content.contains('```') || content.contains('import ') || content.contains('function ')) return 'Code';
    return 'Text';
  }

  void updateItems(List<ClipboardItem> newItems) {
    _allItems = newItems;
    if (!_isSearching) {
      _filteredItems = List.from(_allItems);
    }
    notifyListeners();
  }
}
