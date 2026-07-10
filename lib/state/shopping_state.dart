import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../models/supermarket.dart';

/// Estado central de la app: mantiene la "base de datos" de productos y
/// supermercados en memoria, la persiste localmente (web, Android e iOS) y
/// expone filtros, agrupaciones y operaciones de edición.
class ShoppingState extends ChangeNotifier {
  ShoppingState() {
    _load();
  }

  static const _storageKey = 'bdbuy_data_v3';

  final List<Product> _products = [];
  final List<Supermarket> _supermarkets = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  // --- Filtros ---
  String _search = '';
  final Set<ProductCategory> _categoryFilter = {};
  String? _supermarketFilterId;
  bool _showPurchased = true;

  String get search => _search;
  Set<ProductCategory> get categoryFilter => _categoryFilter;
  String? get supermarketFilterId => _supermarketFilterId;
  bool get showPurchased => _showPurchased;

  bool get hasActiveFilters =>
      _search.isNotEmpty ||
      _categoryFilter.isNotEmpty ||
      _supermarketFilterId != null ||
      !_showPurchased;

  // ----- Carga y guardado -----

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _supermarkets
          ..clear()
          ..addAll(((decoded['supermarkets'] as List?) ?? const [])
              .map((e) => Supermarket.fromJson(e as Map<String, dynamic>)));
        _products
          ..clear()
          ..addAll(((decoded['products'] as List?) ?? const [])
              .map((e) => Product.fromJson(e as Map<String, dynamic>)));
        if (_supermarkets.isEmpty && _products.isEmpty) _seed();
      } else {
        _seed();
      }
    } catch (_) {
      _seed();
    }
    _isLoaded = true;
    notifyListeners();
  }

  void _seed() {
    _supermarkets
      ..clear()
      ..addAll(defaultSupermarkets.map(
          (s) => Supermarket(id: s.id, name: s.name, colorValue: s.colorValue)));
    _products
      ..clear()
      ..addAll(sampleProducts.map((p) => p.copyWith()));
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode({
        'supermarkets': _supermarkets.map((s) => s.toJson()).toList(),
        'products': _products.map((p) => p.toJson()).toList(),
      });
      await prefs.setString(_storageKey, raw);
    } catch (_) {
      // Persistencia best-effort; la app sigue funcionando en memoria.
    }
  }

  // ----- Supermercados -----

  List<Supermarket> get supermarkets => List.unmodifiable(_supermarkets);

  Supermarket? supermarketById(String id) {
    for (final s in _supermarkets) {
      if (s.id == id) return s;
    }
    return null;
  }

  int productCountForSupermarket(String id) =>
      _products.where((p) => p.supermarketIds.contains(id)).length;

  /// Supermercados que tienen al menos un producto (para filtros).
  List<Supermarket> get usedSupermarkets => _supermarkets
      .where((s) => productCountForSupermarket(s.id) > 0)
      .toList();

  /// Categorías que tienen al menos un producto (para filtros).
  List<ProductCategory> get usedCategories {
    final present = _products.map((p) => p.category).toSet();
    return ProductCategory.values.where(present.contains).toList();
  }

  void addSupermarket(String name, int colorValue) {
    _supermarkets.add(Supermarket(
      id: 's${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Supermercado' : name.trim(),
      colorValue: colorValue,
    ));
    notifyListeners();
    _persist();
  }

  void updateSupermarket(String id, {String? name, int? colorValue}) {
    final s = supermarketById(id);
    if (s == null) return;
    if (name != null && name.trim().isNotEmpty) s.name = name.trim();
    if (colorValue != null) s.colorValue = colorValue;
    notifyListeners();
    _persist();
  }

  /// Borra un supermercado y lo quita de todos los productos.
  void deleteSupermarket(String id) {
    _supermarkets.removeWhere((s) => s.id == id);
    for (final p in _products) {
      p.supermarketIds.remove(id);
    }
    if (_supermarketFilterId == id) _supermarketFilterId = null;
    notifyListeners();
    _persist();
  }

  /// Mueve un producto: reemplaza sus supermercados por [targetId].
  void moveProductToSupermarket(String productId, String targetId) {
    final p = _products.firstWhere((e) => e.id == productId);
    p.supermarketIds = [targetId];
    notifyListeners();
    _persist();
  }

  // ----- Lectura de productos -----

  List<Product> get allProducts => List.unmodifiable(_products);

  bool _matchesBase(Product p, {bool applySupermarket = true}) {
    final query = _search.trim().toLowerCase();
    if (query.isNotEmpty && !p.name.toLowerCase().contains(query)) return false;
    if (_categoryFilter.isNotEmpty && !_categoryFilter.contains(p.category)) {
      return false;
    }
    if (applySupermarket &&
        _supermarketFilterId != null &&
        !p.supermarketIds.contains(_supermarketFilterId)) {
      return false;
    }
    return true;
  }

  List<Product> get filteredProducts {
    return _products.where((p) {
      if (!_matchesBase(p)) return false;
      if (!_showPurchased && p.isPurchased) return false;
      return true;
    }).toList();
  }

  Map<ProductCategory, List<Product>> get groupedByCategory {
    final map = <ProductCategory, List<Product>>{};
    for (final p in filteredProducts) {
      map.putIfAbsent(p.category, () => []).add(p);
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => a.key.index.compareTo(b.key.index));
    return {for (final e in sorted) e.key: e.value};
  }

  /// Resumen por supermercado (para la vista "Supermercados").
  List<SupermarketSummary> get supermarketSummaries {
    final result = <SupermarketSummary>[];
    for (final s in _supermarkets) {
      final total =
          _products.where((p) => p.supermarketIds.contains(s.id)).length;
      final pending = _products
          .where((p) => !p.isPurchased && p.supermarketIds.contains(s.id))
          .length;
      if (total > 0) {
        result.add(SupermarketSummary(
            supermarket: s, pending: pending, total: total));
      }
    }
    result.sort((a, b) => b.pending.compareTo(a.pending));
    return result;
  }

  int get pendingCount => _products.where((p) => !p.isPurchased).length;
  int get purchasedCount => _products.where((p) => p.isPurchased).length;
  int get totalCount => _products.length;

  /// Productos pendientes de un supermercado (respeta búsqueda y categoría).
  List<Product> pendingForSupermarket(String id) {
    return _products
        .where((p) =>
            !p.isPurchased &&
            p.supermarketIds.contains(id) &&
            _matchesBase(p, applySupermarket: false))
        .toList()
      ..sort((a, b) => a.category.index.compareTo(b.category.index));
  }

  /// Todos los productos de un supermercado (para la pantalla de gestión).
  List<Product> allForSupermarket(String id) {
    return _products.where((p) => p.supermarketIds.contains(id)).toList()
      ..sort((a, b) => a.category.index.compareTo(b.category.index));
  }

  /// Productos sin ningún supermercado asignado.
  List<Product> get productsWithoutSupermarket =>
      _products.where((p) => p.supermarketIds.isEmpty).toList();

  // ----- Escritura de productos -----

  void togglePurchased(String id) {
    final p = _products.firstWhere((e) => e.id == id);
    p.isPurchased = !p.isPurchased;
    notifyListeners();
    _persist();
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
    _persist();
  }

  void updateProduct(Product updated) {
    final i = _products.indexWhere((e) => e.id == updated.id);
    if (i != -1) {
      _products[i] = updated;
      notifyListeners();
      _persist();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((e) => e.id == id);
    notifyListeners();
    _persist();
  }

  void resetPurchased() {
    for (final p in _products) {
      p.isPurchased = false;
    }
    notifyListeners();
    _persist();
  }

  void restoreSampleData() {
    _seed();
    notifyListeners();
    _persist();
  }

  String newId() => 'p${DateTime.now().microsecondsSinceEpoch}';

  // ----- Filtros (setters) -----

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void toggleCategoryFilter(ProductCategory category) {
    if (_categoryFilter.contains(category)) {
      _categoryFilter.remove(category);
    } else {
      _categoryFilter.add(category);
    }
    notifyListeners();
  }

  void setSupermarketFilter(String? id) {
    _supermarketFilterId = id;
    notifyListeners();
  }

  void setShowPurchased(bool value) {
    _showPurchased = value;
    notifyListeners();
  }

  void clearFilters() {
    _search = '';
    _categoryFilter.clear();
    _supermarketFilterId = null;
    _showPurchased = true;
    notifyListeners();
  }
}

/// Resumen de un supermercado para la vista "Supermercados".
class SupermarketSummary {
  const SupermarketSummary({
    required this.supermarket,
    required this.pending,
    required this.total,
  });

  final Supermarket supermarket;
  final int pending;
  final int total;
}
