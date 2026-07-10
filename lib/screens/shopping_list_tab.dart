import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/product_category.dart';
import '../state/shopping_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/product_card.dart';
import 'product_edit_screen.dart';

/// Vista principal: la lista de la compra agrupada por categorías.
/// En pantallas anchas usa una cuadrícula; en móvil, una sola columna.
class ShoppingListTab extends StatelessWidget {
  const ShoppingListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShoppingState>();
    final grouped = state.groupedByCategory;

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _ProgressHeader()),
        const SliverToBoxAdapter(child: FilterBar()),
        if (grouped.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(),
          )
        else
          for (final entry in grouped.entries) ...[
            SliverToBoxAdapter(
              child: _CategoryHeader(
                category: entry.key,
                count: entry.value.length,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: _ProductSliver(products: entry.value),
            ),
          ],
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}

/// Cuadrícula responsive de tarjetas de producto.
class _ProductSliver extends StatelessWidget {
  const _ProductSliver({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Nº de columnas según el ancho disponible.
    final columns = width >= 1200
        ? 3
        : width >= 720
            ? 2
            : 1;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 176,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final p = products[i];
          return ProductCard(
            product: p,
            onEdit: () => ProductEditScreen.push(context, existing: p),
          );
        },
        childCount: products.length,
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.count});

  final ProductCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Row(
        children: [
          Icon(category.icon, color: category.color, size: 22),
          const SizedBox(width: 8),
          Text(
            category.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: category.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabecera con la barra de progreso de la compra.
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShoppingState>();
    final total = state.totalCount;
    final done = state.purchasedCount;
    final progress = total == 0 ? 0.0 : done / total;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart_checkout,
                  color: scheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(
                'Tu compra',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '$done / $total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: scheme.onPrimaryContainer.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.pendingCount == 0
                ? '¡Todo comprado! 🎉'
                : '${state.pendingCount} productos pendientes',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.remove_shopping_cart_outlined,
                size: 64, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No hay productos que coincidan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba a cambiar los filtros o añade uno nuevo con el botón +',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
