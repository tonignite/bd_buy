import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/supermarket.dart';
import '../state/shopping_state.dart';
import '../widgets/product_card.dart';
import 'product_edit_screen.dart';

/// Vista "Supermercados": muestra a qué supermercados hay que ir y qué
/// productos pendientes comprar en cada uno. Ideal para organizar la ruta.
class SupermarketsTab extends StatelessWidget {
  const SupermarketsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShoppingState>();
    final summaries =
        state.supermarketSummaries.where((s) => s.pending > 0).toList();

    if (summaries.isEmpty) {
      return const _AllDone();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 12),
          child: Text(
            'Supermercados a visitar',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        for (final summary in summaries)
          _SupermarketPanel(supermarket: summary.supermarket),
      ],
    );
  }
}

class _SupermarketPanel extends StatelessWidget {
  const _SupermarketPanel({required this.supermarket});

  final Supermarket supermarket;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShoppingState>();
    final products = state.pendingForSupermarket(supermarket.id);
    if (products.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: supermarket.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.storefront, color: supermarket.color),
          ),
          title: Text(
            supermarket.name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${products.length} productos pendientes'),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: supermarket.color,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${products.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          children: [
            for (final p in products)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ProductCard(
                  product: p,
                  showSupermarkets: false,
                  onEdit: () =>
                      ProductEditScreen.push(context, existing: p),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AllDone extends StatelessWidget {
  const _AllDone();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 72, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              '¡No queda nada por comprar!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando tengas productos pendientes, aquí verás a qué '
              'supermercados tienes que ir.',
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
