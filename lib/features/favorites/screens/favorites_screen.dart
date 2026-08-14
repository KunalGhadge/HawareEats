import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/food_card.dart';
import '../../../shared/widgets/restaurant_card.dart';
import '../../catalog/screens/product_detail_sheet.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final likedFoods = appState.menuItems.where((i) => appState.likedFoodIds.contains(i.id)).toList();
    final likedRestaurants = appState.restaurants.where((r) => appState.likedRestaurantIds.contains(r.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Liked & Favorites', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(text: 'Liked Dishes (${likedFoods.length})'),
            Tab(text: 'Restaurants (${likedRestaurants.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Liked Foods Tab
          likedFoods.isEmpty
              ? _buildEmptyState('No Liked Dishes Yet', 'Tap the heart icon on any burger or pizza to save it here!')
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: likedFoods.length,
                  itemBuilder: (context, index) {
                    final item = likedFoods[index];
                    return FoodCard(
                      item: item,
                      isFavorite: true,
                      onToggleFavorite: () => appState.toggleFavoriteFood(item.id),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => ProductDetailSheet(item: item),
                        );
                      },
                      onAdd: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => ProductDetailSheet(item: item),
                        );
                      },
                    );
                  },
                ),
          // Liked Restaurants Tab
          likedRestaurants.isEmpty
              ? _buildEmptyState('No Liked Restaurants', 'Save your favorite burger joints and pizzerias for quick ordering!')
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: likedRestaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = likedRestaurants[index];
                    return RestaurantCard(
                      restaurant: restaurant,
                      isFavorite: true,
                      onToggleFavorite: () => appState.toggleFavoriteRestaurant(restaurant.id),
                      onTap: () {},
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              child: const Icon(Icons.favorite_border, color: AppColors.primary, size: 54),
            ),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
