import 'product_category.dart';

/// Un producto de la lista de la compra.
///
/// Referencia a los supermercados por su id (no por objeto), para que se
/// puedan renombrar/borrar supermercados sin romper los productos.
class Product {
  Product({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.unit = 'ud',
    List<String>? supermarketIds,
    this.isPurchased = false,
    this.note = '',
  }) : supermarketIds = supermarketIds ?? [];

  final String id;
  String name;
  ProductCategory category;

  /// Cantidad que hay que comprar (p. ej. 2 botes de tomate frito).
  int quantity;

  /// Unidad de medida legible: "ud", "kg", "L", "paq"...
  String unit;

  /// Ids de los supermercados en los que se puede comprar este producto.
  List<String> supermarketIds;

  /// Si ya está comprado (tickado) o pendiente.
  bool isPurchased;

  /// Nota opcional (marca, tamaño, etc.).
  String note;

  Product copyWith({
    String? name,
    ProductCategory? category,
    int? quantity,
    String? unit,
    List<String>? supermarketIds,
    bool? isPurchased,
    String? note,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      supermarketIds: supermarketIds ?? List.of(this.supermarketIds),
      isPurchased: isPurchased ?? this.isPurchased,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'quantity': quantity,
        'unit': unit,
        'supermarketIds': supermarketIds,
        'isPurchased': isPurchased,
        'note': note,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        category: ProductCategory.fromName(json['category'] as String),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        unit: json['unit'] as String? ?? 'ud',
        supermarketIds: ((json['supermarketIds'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(),
        isPurchased: json['isPurchased'] as bool? ?? false,
        note: json['note'] as String? ?? '',
      );
}
