import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class ProductDetailSheet extends StatefulWidget {
  final MenuItem item;

  const ProductDetailSheet({super.key, required this.item});

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  int _quantity = 1;
  final Map<String, CustomizerOption> _selectedSingleOptions = {};
  final Set<CustomizerOption> _selectedMultiOptions = {};
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-select defaults
    for (var group in widget.item.customizerGroups) {
      if (group.maxSelection == 1) {
        final def = group.options.firstWhere((o) => o.isDefault, orElse: () => group.options.first);
        _selectedSingleOptions[group.id] = def;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double total = widget.item.effectivePrice;
    for (var opt in _selectedSingleOptions.values) {
      total += opt.priceDelta;
    }
    for (var opt in _selectedMultiOptions) {
      total += opt.priceDelta;
    }
    return total * _quantity;
  }

  List<SelectedCustomizer> get _formattedCustomizers {
    final list = <SelectedCustomizer>[];
    for (var entry in _selectedSingleOptions.entries) {
      final group = widget.item.customizerGroups.firstWhere((g) => g.id == entry.key);
      list.add(SelectedCustomizer(
        groupTitle: group.title,
        optionName: entry.value.name,
        priceDelta: entry.value.priceDelta,
      ));
    }
    for (var opt in _selectedMultiOptions) {
      list.add(SelectedCustomizer(
        groupTitle: 'Extra Add-on',
        optionName: opt.name,
        priceDelta: opt.priceDelta,
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isFavorite = appState.likedFoodIds.contains(widget.item.id);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image Carousel
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 1.5,
                          child: Image.network(
                            widget.item.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => appState.toggleFavoriteFood(widget.item.id),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              shape: BoxShape.circle,
                              boxShadow: const [AppColors.softShadow],
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? AppColors.primary : AppColors.textMuted,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.item.effectivePrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.item.restaurantName,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  // Nutritional Pills
                  Row(
                    children: [
                      _buildChip(Icons.local_fire_department, '${widget.item.calories} kcal', Colors.orange),
                      const SizedBox(width: 8),
                      _buildChip(Icons.access_time, '${widget.item.prepTimeMinutes} mins', Colors.blue),
                      const SizedBox(width: 8),
                      _buildChip(Icons.star, '${widget.item.rating} (120+)', AppColors.starYellow),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.item.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  // Customizer Groups
                  for (var group in widget.item.customizerGroups) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          group.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        if (group.isRequired)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Required', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (group.maxSelection == 1)
                      // Single Selection Radio
                      for (var opt in group.options)
                        RadioListTile<CustomizerOption>(
                          value: opt,
                          groupValue: _selectedSingleOptions[group.id],
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          title: Text(opt.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          secondary: opt.priceDelta > 0
                              ? Text('+\$${opt.priceDelta.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                              : const Text('Free', style: TextStyle(color: AppColors.textMuted)),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedSingleOptions[group.id] = val);
                            }
                          },
                        )
                    else
                      // Multi Selection Checkbox
                      for (var opt in group.options)
                        CheckboxListTile(
                          value: _selectedMultiOptions.contains(opt),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          title: Text(opt.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          secondary: Text('+\$${opt.priceDelta.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedMultiOptions.add(opt);
                              } else {
                                _selectedMultiOptions.remove(opt);
                              }
                            });
                          },
                        ),
                    const SizedBox(height: 14),
                  ],
                  // Special Instructions
                  const Text(
                    'Special Instructions',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. Extra napkins, no spicy sauce please...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Sticky Bottom Bar: Quantity & Add Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Row(
              children: [
                // Quantity Stepper
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Add to Cart Button
                Expanded(
                  child: CustomButton(
                    text: 'Add to Basket • \$${_totalPrice.toStringAsFixed(2)}',
                    onPressed: () {
                      appState.addToCart(
                        widget.item,
                        quantity: _quantity,
                        customizers: _formattedCustomizers,
                        instructions: _notesController.text.trim(),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${widget.item.name} to Basket!'),
                          backgroundColor: AppColors.successGreen,
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'View Basket',
                            textColor: Colors.white,
                            onPressed: () {
                              // Cart trigger
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
