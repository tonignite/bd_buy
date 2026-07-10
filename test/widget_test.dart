import 'package:bd_buy/models/product.dart';
import 'package:bd_buy/models/product_category.dart';
import 'package:bd_buy/models/supermarket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Product se serializa y deserializa correctamente', () {
    final p = Product(
      id: 'x1',
      name: 'Tomate frito',
      category: ProductCategory.despensa,
      quantity: 2,
      unit: 'bote',
      supermarketIds: ['merca', 'carre'],
      isPurchased: true,
      note: 'Bote grande',
    );

    final restored = Product.fromJson(p.toJson());

    expect(restored.id, p.id);
    expect(restored.name, p.name);
    expect(restored.category, ProductCategory.despensa);
    expect(restored.quantity, 2);
    expect(restored.supermarketIds, contains('merca'));
    expect(restored.isPurchased, isTrue);
    expect(restored.note, 'Bote grande');
  });

  test('Supermarket se serializa y deserializa correctamente', () {
    final s =
        Supermarket(id: 'merca', name: 'Mercadona', colorValue: 0xFF00A650);
    final restored = Supermarket.fromJson(s.toJson());

    expect(restored.id, 'merca');
    expect(restored.name, 'Mercadona');
    expect(restored.colorValue, 0xFF00A650);
  });

  test('copyWith conserva el id y cambia solo lo indicado', () {
    final p = Product(
      id: 'x2',
      name: 'Leche',
      category: ProductCategory.lacteos,
    );
    final updated = p.copyWith(quantity: 6, isPurchased: true);

    expect(updated.id, 'x2');
    expect(updated.name, 'Leche');
    expect(updated.quantity, 6);
    expect(updated.isPurchased, isTrue);
  });
}
