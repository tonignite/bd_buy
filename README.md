# 🛒 BDBuy

App **visual** para gestionar tu lista de la compra: organiza los productos por
**tipo** (verduras, carne, lácteos…) y por **supermercado**, marca lo comprado
y controla las **cantidades**. Hecha en **Flutter**, así que corre en **web**,
**Android** e **iOS** con el mismo código.

## ✨ Funcionalidades

- **Base de datos de productos** con datos de ejemplo precargados.
- **Filtro por tipo/categoría** (chips de colores con iconos).
- **Filtro por supermercado**.
- **Buscador** por nombre.
- **Tickar comprado / pendiente** con un toque (barra de progreso de la compra).
- **Cantidad por producto** con botones +/− (ej.: 2 botes de tomate frito).
- **Vista "Supermercados"**: te dice a qué súper ir y qué comprar en cada uno.
- **Añadir / editar / borrar** productos.
- **Diseño responsive**: navegación inferior en móvil y barra lateral en
  pantallas anchas; las tarjetas se reorganizan en 1, 2 o 3 columnas.
- **Persistencia local** (funciona en web, Android e iOS).
- Modo claro/oscuro automático (Material 3).

## 🚀 Cómo ejecutarlo

Necesitas el SDK de Flutter (aún no está instalado en este equipo).

### 1. Instalar Flutter

```bash
# Opción rápida en Arch/CachyOS:
sudo pacman -S --needed git base-devel
# Instala Flutter (elige una):
#   - Vía AUR:   yay -S flutter
#   - O manual:  https://docs.flutter.dev/get-started/install/linux
flutter doctor
```

### 2. Generar las carpetas de plataforma

Este proyecto incluye el código (`lib/`), `pubspec.yaml` y los tests. Las
carpetas de cada plataforma se generan con un comando (no sobreescribe `lib/`):

```bash
cd /home/toni/Escritorio/dev/bd_buy
flutter create . --platforms=web,android,ios,linux
flutter pub get
```

### 3. Lanzar la app

```bash
# En el navegador (Chrome):
flutter run -d chrome

# En Linux de escritorio:
flutter run -d linux

# En un móvil/emulador Android conectado:
flutter run -d android
```

### 4. Compilar para publicar

```bash
flutter build web       # -> build/web
flutter build apk       # Android
flutter build appbundle # Android (Google Play)
flutter build ios       # iOS (requiere macOS + Xcode)
```

## 🗂️ Estructura

```
lib/
├── main.dart                     # Arranque de la app
├── models/
│   ├── product.dart              # Modelo de producto (+ JSON)
│   ├── product_category.dart     # Categorías (icono + color)
│   └── supermarket.dart          # Supermercados (color)
├── data/
│   └── sample_data.dart          # Base de datos de ejemplo
├── state/
│   └── shopping_state.dart       # Estado, filtros y persistencia
├── theme/
│   └── app_theme.dart            # Tema Material 3
├── screens/
│   ├── home_screen.dart          # Navegación responsive
│   ├── shopping_list_tab.dart    # Lista agrupada por categoría
│   └── supermarkets_tab.dart     # A qué súper ir y qué comprar
└── widgets/
    ├── product_card.dart         # Tarjeta de producto
    ├── quantity_stepper.dart     # Control de cantidad +/−
    ├── filter_bar.dart           # Buscador + filtros
    └── add_edit_product_sheet.dart  # Alta/edición de producto
```

## 🧩 Notas técnicas

- **Estado**: `provider` + `ChangeNotifier` (`ShoppingState`).
- **Persistencia**: `shared_preferences` (JSON). Fácil de migrar a `sqflite`
  o `drift` si quieres una BD SQL completa en el futuro.
- **Datos de ejemplo**: se cargan solo la primera vez; luego se guardan tus
  cambios. Puedes restaurarlos desde el menú ⋮ → *Restaurar datos de ejemplo*.
```
# bd_buy
