import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/food_card.dart';
import 'product_detail_sheet.dart';

class CategoryDetailScreen extends StatefulWidget {
  final FoodCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  String _selectedSubFilter = 'All';
  String _searchQuery = '';
  final List<String> _subFilters = ['All', 'Popular', 'Chicken', 'Beef', 'Veg & Cheese', 'Deals'];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final allItems = appState.menuItems.where((i) => i.categoryId == widget.category.id || widget.category.id == 'cat_1').toList();

    // Filter items
    final filteredItems = allItems.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.restaurantName.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedSubFilter == 'All') return true;
      if (_selectedSubFilter == 'Popular') return item.isBestSeller;
      if (_selectedSubFilter == 'Chicken') return item.name.toLowerCase().contains('chicken');
      if (_selectedSubFilter == 'Beef') return item.name.toLowerCase().contains('beef') || item.name.toLowerCase().contains('bacon');
      if (_selectedSubFilter == 'Veg & Cheese') return item.isVeg || item.name.toLowerCase().contains('cheese') || item.name.toLowerCase().contains('paneer');
      if (_selectedSubFilter == 'Deals') return item.discountedPrice != null;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.category.iconEmoji} ${widget.category.name} Category',
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.textDark),
            onPressed: () {
              // Filters
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search delicious ${widget.category.name.toLowerCase()}s...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Pills Carousel
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _subFilters.map((filter) {
                      final isSelected = _selectedSubFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          backgroundColor: AppColors.inputBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedSubFilter = filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Items Grid
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 60, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No ${widget.category.name}s found matching "$_searchQuery"',
                          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isFav = appState.likedFoodIds.contains(item.id);

                      return FoodCard(
                        item: item,
                        isFavorite: isFav,
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
          ),
        ],
      ),
    );
  }
}
