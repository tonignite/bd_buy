import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/supermarket.dart';
import '../state/shopping_state.dart';
import 'product_edit_screen.dart';

/// Pantalla de gestión: administra los supermercados (añadir, renombrar,
/// recolorear, borrar) y permite mover/editar los productos de cada uno.
class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShoppingState>();
    final orphans = state.productsWithoutSupermarket;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
          child: Text(
            'Gestionar supermercados',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
          child: Text(
            'Añade o borra supermercados y mueve productos entre ellos.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _editSupermarketDialog(context),
          icon: const Icon(Icons.add_business_outlined),
          label: const Text('Añadir supermercado'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: 8),
        for (final s in state.supermarkets)
          _SupermarketPanel(supermarket: s),
        if (orphans.isNotEmpty) _OrphanPanel(products: orphans),
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
    final products = state.allForSupermarket(supermarket.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 16,
            height: 40,
            decoration: BoxDecoration(
              color: supermarket.color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          title: Text(
            supermarket.name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${products.length} productos'),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'edit') {
                _editSupermarketDialog(context, existing: supermarket);
              } else if (v == 'delete') {
                _confirmDeleteSupermarket(context, supermarket);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Renombrar / color'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Borrar supermercado'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          children: [
            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Sin productos todavía.'),
              )
            else
              for (final p in products)
                _ProductRow(product: p, currentSupermarketId: supermarket.id),
          ],
        ),
      ),
    );
  }
}

class _OrphanPanel extends StatelessWidget {
  const _OrphanPanel({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Sin supermercado',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${products.length} productos'),
          children: [
            for (final p in products)
              _ProductRow(product: p, currentSupermarketId: null),
          ],
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.currentSupermarketId,
  });

  final Product product;
  final String? currentSupermarketId;

  @override
  Widget build(BuildContext context) {
    final state = context.read<ShoppingState>();
    return ListTile(
      dense: true,
      leading: Icon(product.category.icon, color: product.category.color),
      title: Text(product.name),
      subtitle: Text('${product.category.label} · ×${product.quantity} ${product.unit}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mover a otro supermercado.
          PopupMenuButton<String>(
            icon: const Icon(Icons.drive_file_move_outline),
            tooltip: 'Mover a...',
            onSelected: (targetId) =>
                state.moveProductToSupermarket(product.id, targetId),
            itemBuilder: (_) => [
              for (final s in state.supermarkets)
                if (s.id != currentSupermarketId)
                  PopupMenuItem(
                    value: s.id,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: s.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Text('Mover a ${s.name}'),
                      ],
                    ),
                  ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () =>
                ProductEditScreen.push(context, existing: product),
          ),
        ],
      ),
    );
  }
}

/// Diálogo para crear o editar un supermercado (nombre + color).
Future<void> _editSupermarketDialog(
  BuildContext context, {
  Supermarket? existing,
}) async {
  final state = context.read<ShoppingState>();
  final ctrl = TextEditingController(text: existing?.name ?? '');
  int selectedColor = existing?.colorValue ?? Supermarket.palette.first;

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: Text(existing == null ? 'Nuevo supermercado' : 'Editar supermercado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Color', style: Theme.of(ctx).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final c in Supermarket.palette)
                  GestureDetector(
                    onTap: () => setLocal(() => selectedColor = c),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == c
                              ? Theme.of(ctx).colorScheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: selectedColor == c
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              if (existing == null) {
                state.addSupermarket(name, selectedColor);
              } else {
                state.updateSupermarket(existing.id,
                    name: name, colorValue: selectedColor);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _confirmDeleteSupermarket(
  BuildContext context,
  Supermarket supermarket,
) async {
  final state = context.read<ShoppingState>();
  final count = state.productCountForSupermarket(supermarket.id);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Borrar "${supermarket.name}"'),
      content: Text(count == 0
          ? '¿Seguro que quieres borrar este supermercado?'
          : 'Se quitará de $count producto(s), que quedarán sin supermercado. '
              'No se borrará ningún producto.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Borrar'),
        ),
      ],
    ),
  );
  if (ok == true) {
    state.deleteSupermarket(supermarket.id);
  }
}
