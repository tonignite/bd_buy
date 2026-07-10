import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/product_category.dart';
import '../state/shopping_state.dart';

/// Pantalla completa para crear o editar un producto.
class ProductEditScreen extends StatefulWidget {
  const ProductEditScreen({super.key, this.existing});

  /// Si es null, se crea uno nuevo; si no, se edita el existente.
  final Product? existing;

  static Future<void> push(BuildContext context, {Product? existing}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductEditScreen(existing: existing),
      ),
    );
  }

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _unitCtrl;
  late ProductCategory _category;
  late Set<String> _supermarketIds;
  late int _quantity;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _noteCtrl = TextEditingController(text: p?.note ?? '');
    _unitCtrl = TextEditingController(text: p?.unit ?? 'ud');
    _category = p?.category ?? ProductCategory.verduras;
    _supermarketIds = {...?p?.supermarketIds};
    _quantity = p?.quantity ?? 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ponle un nombre al producto')),
      );
      return;
    }
    final state = context.read<ShoppingState>();
    final unit = _unitCtrl.text.trim().isEmpty ? 'ud' : _unitCtrl.text.trim();

    if (_isEditing) {
      state.updateProduct(widget.existing!.copyWith(
        name: name,
        category: _category,
        quantity: _quantity,
        unit: unit,
        supermarketIds: _supermarketIds.toList(),
        note: _noteCtrl.text.trim(),
      ));
    } else {
      state.addProduct(Product(
        id: state.newId(),
        name: name,
        category: _category,
        quantity: _quantity,
        unit: unit,
        supermarketIds: _supermarketIds.toList(),
        note: _noteCtrl.text.trim(),
      ));
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar producto'),
        content: Text('¿Seguro que quieres borrar "${widget.existing!.name}"?'),
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
    if (ok == true && mounted) {
      context.read<ShoppingState>().deleteProduct(widget.existing!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShoppingState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Borrar',
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _QuantityField(
                    quantity: _quantity,
                    onChanged: (v) => setState(() => _quantity = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(labelText: 'Unidad'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text('Categoría', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cat in ProductCategory.values)
                  ChoiceChip(
                    avatar: Icon(cat.icon,
                        size: 18,
                        color: _category == cat ? Colors.white : cat.color),
                    label: Text(cat.label),
                    selected: _category == cat,
                    selectedColor: cat.color,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: _category == cat ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _category = cat),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Text('Supermercados',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text(
                  'Se compra en...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in state.supermarkets)
                  FilterChip(
                    label: Text(s.name),
                    selected: _supermarketIds.contains(s.id),
                    selectedColor: s.color,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _supermarketIds.contains(s.id)
                          ? Colors.white
                          : null,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() {
                      if (_supermarketIds.contains(s.id)) {
                        _supermarketIds.remove(s.id);
                      } else {
                        _supermarketIds.add(s.id);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
                hintText: 'Marca, tamaño...',
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Guardar cambios' : 'Añadir producto'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityField extends StatelessWidget {
  const _QuantityField({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Cantidad'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Text(
            '$quantity',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}
