import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/features/categories/presentation/controllers/category_browser_providers.dart';

/// Shell com a barra de navegação inferior fixa (Home, Categorias,
/// Carrinho, Festas, Perfil) — replica a estrutura dos protótipos em
/// `Desgin/home_happfest/code.html`.
class AppShellPage extends ConsumerWidget {
  const AppShellPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _categoriesIndex = 1;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view),
      label: 'Categorias',
    ),
    NavigationDestination(
      icon: Icon(Icons.shopping_cart_outlined),
      selectedIcon: Icon(Icons.shopping_cart),
      label: 'Carrinho',
    ),
    NavigationDestination(
      icon: Icon(Icons.celebration_outlined),
      selectedIcon: Icon(Icons.celebration),
      label: 'Festas',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          final isReselect = index == navigationShell.currentIndex;
          // Tocar de novo na aba Categorias volta para a raiz.
          if (isReselect && index == _categoriesIndex) {
            ref.read(categoryTrailProvider.notifier).reset();
          }
          navigationShell.goBranch(index, initialLocation: isReselect);
        },
        destinations: _destinations,
      ),
    );
  }
}
