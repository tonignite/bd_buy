import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/shopping_state.dart';

/// Tarjeta visual de un producto: icono de categoría, nombre, cantidad,
/// supermercados, botón de editar y control de "Comprado".
///
/// Pulsar la tarjeta NO marca comprado: eso solo lo hace el botón "Comprado".
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.showSupermarkets = true,
  });

  final Product product;
  final VoidCallback? onEdit;
  final bool showSupermarkets;

  @override
  Widget build(BuildContext context) {
    final state = context.read<ShoppingState>();
    final scheme = Theme.of(context).colorScheme;
    final done = product.isPurchased;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono de categoría con su color.
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: product.category.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(product.category.icon,
                  color: product.category.color, size: 24),
            ),
            const SizedBox(width: 12),
            // Datos principales.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: done
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: done ? scheme.onSurfaceVariant : null,
                              ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _QuantityBadge(quantity: product.quantity, unit: product.unit),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: product.category.color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (product.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.note,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (showSupermarkets && product.supermarketIds.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final id in product.supermarketIds)
                          if (state.supermarketById(id) != null)
                            _SupermarketTag(
                                supermarketName:
                                    state.supermarketById(id)!.name,
                                color: state.supermarketById(id)!.color),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _PurchaseToggle(
                        purchased: done,
                        onTap: () => state.togglePurchased(product.id),
                      ),
                      const Spacer(),
                      if (onEdit != null)
                        OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Editar'),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de cantidad de solo lectura (se edita en la pantalla de edición).
class _QuantityBadge extends StatelessWidget {
  const _QuantityBadge({required this.quantity, required this.unit});

  final int quantity;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '×$quantity $unit',
        style: TextStyle(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Control claramente etiquetado "Comprado": pastilla que se rellena al
/// marcarlo. Deja claro que es el tick de compra, no una selección.
class _PurchaseToggle extends StatelessWidget {
  const _PurchaseToggle({required this.purchased, required this.onTap});

  final bool purchased;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: purchased ? 'Marcar como pendiente' : 'Marcar como comprado',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: purchased ? scheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: purchased ? scheme.primary : scheme.outline,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  purchased ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18,
                  color: purchased ? Colors.white : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Comprado',
                  style: TextStyle(
                    color: purchased ? Colors.white : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupermarketTag extends StatelessWidget {
  const _SupermarketTag({required this.supermarketName, required this.color});

  final String supermarketName;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            supermarketName,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
