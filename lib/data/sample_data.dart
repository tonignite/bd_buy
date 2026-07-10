import '../models/product.dart';
import '../models/product_category.dart';
import '../models/supermarket.dart';

/// Supermercados por defecto de BDBuy.
final List<Supermarket> defaultSupermarkets = [
  Supermarket(id: 'any', name: 'Donde sea', colorValue: 0xFF546E7A),
  Supermarket(id: 'combo', name: 'Super Combo', colorValue: 0xFF7B3FA0),
  Supermarket(id: 'merca', name: 'Mercadona', colorValue: 0xFF00A650),
  Supermarket(id: 'carre', name: 'Carrefour', colorValue: 0xFF004E9F),
  Supermarket(id: 'alcampo', name: 'Alcampo', colorValue: 0xFFE30613),
  Supermarket(id: 'lidl', name: 'Lidl', colorValue: 0xFFFFB300),
  Supermarket(id: 'aldi', name: 'Aldi', colorValue: 0xFF1E4B9B),
];

/// Lista de la compra real de BDBuy (datos iniciales).
final List<Product> sampleProducts = [
  // =========================== DONDE SEA ============================
  _p('pasta de arroz', ProductCategory.despensa, 'any'),
  _p('Vino blanco', ProductCategory.bebidas, 'any', unit: 'bot'),
  _p('Zumitos', ProductCategory.bebidas, 'any', unit: 'pack'),
  _p('Yuba', ProductCategory.despensa, 'any'),
  _p('Pipas de calabaza', ProductCategory.despensa, 'any'),
  _p('Pasta miso', ProductCategory.despensa, 'any'),
  _p('Lentejas rojas', ProductCategory.despensa, 'any'),
  _p('Pan de hamburguesa', ProductCategory.panaderia, 'any'),
  _p('Queso raclette', ProductCategory.lacteos, 'any', note: '¡QUESOOOOOOO!'),
  _p('Sésamo', ProductCategory.despensa, 'any'),
  _p('Masa de pizza', ProductCategory.despensa, 'any'),
  _p('Sazonador', ProductCategory.despensa, 'any'),
  _p('Preparado para burritos', ProductCategory.despensa, 'any'),
  _p('Pasta', ProductCategory.despensa, 'any'),
  _p('Champiñones', ProductCategory.verduras, 'any'),
  _p('Setas', ProductCategory.verduras, 'any'),
  _p('Horchata', ProductCategory.bebidas, 'any'),
  _p('Desodorante', ProductCategory.higiene, 'any'),
  _p('Cristalmina', ProductCategory.higiene, 'any', note: 'Botiquín'),
  _p('Agua oxigenada', ProductCategory.higiene, 'any', note: 'Botiquín'),
  _p('Fideos de arroz', ProductCategory.despensa, 'any'),
  _p('Huevos', ProductCategory.lacteos, 'any'),
  _p('Vinagre de limpieza', ProductCategory.limpieza, 'any'),
  _p('Fideos de sopa', ProductCategory.despensa, 'any'),
  _p('Perejil', ProductCategory.verduras, 'any'),
  _p('Maicena', ProductCategory.despensa, 'any'),
  _p('Mostaza Dijon', ProductCategory.despensa, 'any'),
  _p('Aceitunas negras', ProductCategory.despensa, 'any', unit: 'lata'),
  _p('Salsa de soja', ProductCategory.despensa, 'any'),
  _p('Algas', ProductCategory.despensa, 'any'),
  _p('Gazpacho', ProductCategory.despensa, 'any'),
  _p('Salsa agridulce', ProductCategory.despensa, 'any'),
  _p('Lentejas', ProductCategory.despensa, 'any', unit: 'bote'),
  _p('Quinoa', ProductCategory.despensa, 'any'),
  _p('Gel de ducha', ProductCategory.higiene, 'any'),
  _p('Garbanzos', ProductCategory.despensa, 'any', unit: 'bote'),

  // =========================== SUPER COMBO ==========================
  _p('Papel de cocina', ProductCategory.limpieza, 'combo'),
  _p('Papel higiénico', ProductCategory.higiene, 'combo', unit: 'pack'),
  _p('Tomate triturado', ProductCategory.despensa, 'combo', quantity: 2),
  _p('Berenjena', ProductCategory.verduras, 'combo'),
  _p('Aguacate', ProductCategory.verduras, 'combo'),
  _p('Zanahorias', ProductCategory.verduras, 'combo'),
  _p('Boniatos', ProductCategory.verduras, 'combo'),
  _p('Pimiento rojo', ProductCategory.verduras, 'combo'),
  _p('Pimiento verde', ProductCategory.verduras, 'combo'),
  _p('Calabacín', ProductCategory.verduras, 'combo'),
  _p('Alcaparras', ProductCategory.despensa, 'combo'),
  _p('Caja de pañuelos', ProductCategory.higiene, 'combo'),
  _p('Papel vegetal', ProductCategory.limpieza, 'combo'),
  _p('Toallitas', ProductCategory.higiene, 'combo'),
  _p('Cebollas', ProductCategory.verduras, 'combo'),
  _p('Patatas', ProductCategory.verduras, 'combo'),
  _p('Ajos', ProductCategory.verduras, 'combo'),

  // ============================ MERCADONA ===========================
  _p('Piñones', ProductCategory.despensa, 'merca'),
  _p('Pack verduras para cocido', ProductCategory.verduras, 'merca'),
  _p('Arroz congelado', ProductCategory.congelados, 'merca'),
  _p('Leche de coco', ProductCategory.despensa, 'merca'),
  _p('Albahaca', ProductCategory.verduras, 'merca'),
  _p('Pienso gatos (malo)', ProductCategory.mascotas, 'merca'),
  _p('Rollitos primavera', ProductCategory.congelados, 'merca'),
  _p('Edamame congelado', ProductCategory.congelados, 'merca'),
  _p('Cebolla crujiente', ProductCategory.despensa, 'merca'),
  _p('Yatekomos', ProductCategory.despensa, 'merca', quantity: 2),
  _p('Nata de soja', ProductCategory.lacteos, 'merca'),
  _p('Yogures de soja', ProductCategory.lacteos, 'merca'),
  _p('Tofu', ProductCategory.despensa, 'merca'),
  _p('Tortillas de fajitas', ProductCategory.panaderia, 'merca'),
  _p('Hummus', ProductCategory.despensa, 'merca'),
  _p('Masas de pizza', ProductCategory.despensa, 'merca'),
  _p('Salsa sweet chili', ProductCategory.despensa, 'merca'),
  _p('Soja texturizada', ProductCategory.despensa, 'merca'),
  _p('Pan de molde', ProductCategory.panaderia, 'merca'),
  _p('Toallitas', ProductCategory.higiene, 'merca'),
  _p('Chicles', ProductCategory.otros, 'merca'),
  _p('Pisto', ProductCategory.despensa, 'merca'),
  _p('Sopa de miso', ProductCategory.despensa, 'merca'),
  _p('Pienso gatos (bueno)', ProductCategory.mascotas, 'merca'),
  _p('Bolsas de basura', ProductCategory.limpieza, 'merca'),
  _p('Masas de empanada', ProductCategory.despensa, 'merca'),
  _p('Salsa miel y mostaza', ProductCategory.despensa, 'merca'),
  _p('Oxígeno activo', ProductCategory.limpieza, 'merca'),
  _p('Arena de gatos aglomerante', ProductCategory.mascotas, 'merca'),

  // ============================ CARREFOUR ===========================
  _p('Seitán', ProductCategory.despensa, 'carre'),
  _p('Sazonador chili', ProductCategory.despensa, 'carre'),
  _p('Levadura nutricional', ProductCategory.despensa, 'carre'),
  _p('Café', ProductCategory.bebidas, 'carre', unit: 'paq'),
  _p('Descafeinado', ProductCategory.bebidas, 'carre', unit: 'paq'),

  // ============================= ALCAMPO ============================
  _p('Seitán', ProductCategory.despensa, 'alcampo'),
  _p('Friegasuelos', ProductCategory.limpieza, 'alcampo'),
  _p('Fairy (lavavajillas)', ProductCategory.limpieza, 'alcampo'),
  _p('Limpiador de váter', ProductCategory.limpieza, 'alcampo'),
  _p('Detergente', ProductCategory.limpieza, 'alcampo'),
  _p('Regañás', ProductCategory.despensa, 'alcampo'),
  _p('Pasta de dientes', ProductCategory.higiene, 'alcampo'),

  // ============================== LIDL =============================
  _p('Tofu ahumado', ProductCategory.despensa, 'lidl'),
  _p('Leche', ProductCategory.lacteos, 'lidl', unit: 'brick'),

  // ============================== ALDI =============================
  _p('Hamburguesas', ProductCategory.carne, 'aldi'),
  _p('Salmón ahumado', ProductCategory.pescado, 'aldi'),
];

/// Contador incremental para generar ids estables (p1, p2, ...).
int _idSeq = 0;

/// Ayudante para declarar productos de forma compacta.
Product _p(
  String name,
  ProductCategory category,
  String supermarketId, {
  int quantity = 1,
  String unit = 'ud',
  String note = '',
}) {
  _idSeq++;
  return Product(
    id: 'p$_idSeq',
    name: name,
    category: category,
    quantity: quantity,
    unit: unit,
    supermarketIds: [supermarketId],
    note: note,
  );
}
