import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shopping_state.dart';

/// Barra de filtros: búsqueda, categorías (chips) y supermercado.
/// Solo muestra categorías y supermercados que tienen productos.
class FilterBar extends StatelessWidget {
  const FilterBar({super.key, this.showSupermarketFilter = true});

  final bool showSupermarketFilter;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShoppingState>();
    final categories = state.usedCategories;
    final supermarkets = state.usedSupermarkets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buscador.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: state.setSearch,
            decoration: InputDecoration(
              hintText: 'Buscar producto...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => state.setSearch(''),
                    )
                  : null,
            ),
          ),
        ),
        // Chips de categoría.
        if (categories.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final cat in categories)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      avatar: Icon(
                        cat.icon,
                        size: 18,
                        color: state.categoryFilter.contains(cat)
                            ? Colors.white
                            : cat.color,
                      ),
                      label: Text(cat.label),
                      selected: state.categoryFilter.contains(cat),
                      selectedColor: cat.color,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: state.categoryFilter.contains(cat)
                            ? Colors.white
                            : null,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => state.toggleCategoryFilter(cat),
                    ),
                  ),
              ],
            ),
          ),
        if (showSupermarketFilter && supermarkets.isNotEmpty) ...[
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('Todos los súper'),
                    selected: state.supermarketFilterId == null,
                    onSelected: (_) => state.setSupermarketFilter(null),
                  ),
                ),
                for (final s in supermarkets)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(s.name),
                      selected: state.supermarketFilterId == s.id,
                      selectedColor: s.color,
                      labelStyle: TextStyle(
                        color: state.supermarketFilterId == s.id
                            ? Colors.white
                            : null,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => state.setSupermarketFilter(
                        state.supermarketFilterId == s.id ? null : s.id,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        // Fila de opciones: mostrar comprados + limpiar filtros.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Checkbox(
                value: state.showPurchased,
                onChanged: (v) => state.setShowPurchased(v ?? true),
              ),
              const Text('Mostrar comprados'),
              const Spacer(),
              if (state.hasActiveFilters)
                TextButton.icon(
                  onPressed: state.clearFilters,
                  icon: const Icon(Icons.filter_alt_off, size: 18),
                  label: const Text('Limpiar'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
