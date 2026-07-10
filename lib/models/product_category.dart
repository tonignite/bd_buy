import 'package:flutter/material.dart';

/// Tipos / categorías de producto que se pueden comprar.
///
/// Cada categoría lleva asociada una etiqueta legible, un icono y un color
/// para que la interfaz sea muy visual y se distingan de un vistazo.
enum ProductCategory {
  verduras('Verduras', Icons.eco, Color(0xFF4CAF50)),
  carne('Carne', Icons.kebab_dining, Color(0xFFE53935)),
  pescado('Pescado', Icons.set_meal, Color(0xFF29B6F6)),
  lacteos('Lácteos', Icons.egg_alt, Color(0xFFFFB300)),
  panaderia('Panadería', Icons.bakery_dining, Color(0xFF8D6E63)),
  bebidas('Bebidas', Icons.local_drink, Color(0xFF26C6DA)),
  despensa('Despensa', Icons.rice_bowl, Color(0xFFAB47BC)),
  congelados('Congelados', Icons.ac_unit, Color(0xFF5C6BC0)),
  limpieza('Limpieza', Icons.cleaning_services, Color(0xFF00897B)),
  higiene('Higiene', Icons.soap, Color(0xFFEC407A)),
  mascotas('Mascotas', Icons.pets, Color(0xFF795548)),
  otros('Otros', Icons.shopping_bag, Color(0xFF78909C));

  const ProductCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// Reconstruye la categoría a partir de su nombre almacenado.
  static ProductCategory fromName(String name) {
    return ProductCategory.values.firstWhere(
      (c) => c.name == name,
      orElse: () => ProductCategory.otros,
    );
  }
}
