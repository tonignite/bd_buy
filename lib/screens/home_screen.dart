import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shopping_state.dart';
import 'manage_screen.dart';
import 'product_edit_screen.dart';
import 'shopping_list_tab.dart';
import 'supermarkets_tab.dart';

/// Pantalla principal con navegación adaptable:
/// - En móvil: barra de navegación inferior.
/// - En tablet/escritorio/web ancho: barra lateral (NavigationRail).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _destinations = [
    _Dest('Lista', Icons.list_alt, Icons.list_alt_outlined),
    _Dest('Supermercados', Icons.storefront, Icons.storefront_outlined),
    _Dest('Gestionar', Icons.tune, Icons.tune_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShoppingState>();
    final isWide = MediaQuery.of(context).size.width >= 720;

    if (!state.isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      const ShoppingListTab(),
      const SupermarketsTab(),
      const ManageScreen(),
    ];

    final content = SafeArea(
      child: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.shopping_basket,
                    color: Theme.of(context).colorScheme.primary, size: 30),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.outlined),
                    selectedIcon: Icon(d.filled),
                    label: Text(d.label),
                  ),
              ],
            ),
          if (isWide) const VerticalDivider(width: 1),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: pages[_index],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Icon(Icons.shopping_basket,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('BDBuy',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _onMenu(context, value),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.restart_alt),
                  title: Text('Empezar compra nueva'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'sample',
                child: ListTile(
                  leading: Icon(Icons.dataset),
                  title: Text('Restaurar datos de ejemplo'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: content,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ProductEditScreen.push(context),
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                    icon: Icon(d.outlined),
                    selectedIcon: Icon(d.filled),
                    label: d.label,
                  ),
              ],
            ),
    );
  }

  Future<void> _onMenu(BuildContext context, String value) async {
    final state = context.read<ShoppingState>();
    final messenger = ScaffoldMessenger.of(context);
    if (value == 'reset') {
      final ok = await _confirm(
        context,
        title: 'Empezar compra nueva',
        message: 'Se marcarán todos los productos como pendientes. '
            'No se borrará ningún producto.',
      );
      if (ok) {
        state.resetPurchased();
        messenger.showSnackBar(
          const SnackBar(content: Text('Lista reiniciada')),
        );
      }
    } else if (value == 'sample') {
      final ok = await _confirm(
        context,
        title: 'Restaurar datos de ejemplo',
        message: 'Se reemplazarán tus productos por la lista de ejemplo. '
            'Esta acción no se puede deshacer.',
      );
      if (ok) {
        state.restoreSampleData();
        messenger.showSnackBar(
          const SnackBar(content: Text('Datos de ejemplo restaurados')),
        );
      }
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _Dest {
  const _Dest(this.label, this.filled, this.outlined);
  final String label;
  final IconData filled;
  final IconData outlined;
}
