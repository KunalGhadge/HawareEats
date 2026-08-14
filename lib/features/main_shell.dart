import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state_provider.dart';
import 'home/screens/home_screen.dart';
import 'catalog/screens/categories_screen.dart';
import 'orders/screens/orders_screen.dart';
import 'favorites/screens/favorites_screen.dart';
import 'profile/screens/profile_screen.dart';
import 'cart/screens/cart_screen.dart';
import 'merchant/screens/merchant_dashboard_screen.dart';
import 'driver_hub/screens/driver_dashboard_screen.dart';
import 'admin/screens/admin_dashboard_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedTabIndex = 0;

  final List<Widget> _customerTabs = const [
    HomeScreen(),
    CategoriesScreen(),
    OrdersScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final role = appState.currentRole;

    // Multi-Role Dynamic Redirection
    if (role == UserRole.restaurantOwner) {
      return const MerchantDashboardScreen();
    } else if (role == UserRole.driver) {
      return const DriverDashboardScreen();
    } else if (role == UserRole.admin) {
      return const AdminDashboardScreen();
    }

    // Default Customer App Mode
    return Scaffold(
      body: IndexedStack(
        index: _selectedTabIndex,
        children: _customerTabs,
      ),
      // Floating Cart Pill
      floatingActionButton: appState.cartCount > 0
          ? Container(
              margin: const EdgeInsets.only(bottom: 50),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const CartScreen()),
                  );
                },
                backgroundColor: AppColors.primary,
                elevation: 8,
                icon: const Icon(Icons.shopping_bag, color: Colors.white),
                label: Row(
                  children: [
                    Text(
                      '${appState.cartCount} items • \$${appState.cartTotal.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Curved Modern Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) => setState(() => _selectedTabIndex = index),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_outline),
              activeIcon: const Icon(Icons.favorite),
              label: 'Liked',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
