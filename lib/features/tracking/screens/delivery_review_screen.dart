import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/custom_button.dart';

class DeliveryReviewScreen extends StatefulWidget {
  final Order order;

  const DeliveryReviewScreen({super.key, required this.order});

  @override
  State<DeliveryReviewScreen> createState() => _DeliveryReviewScreenState();
}

class _DeliveryReviewScreenState extends State<DeliveryReviewScreen> {
  int _restaurantRating = 5;
  int _driverRating = 5;
  final Set<String> _selectedTags = {'Food was hot 🔥', 'Super fast delivery 🛵'};
  final TextEditingController _reviewController = TextEditingController();

  final List<String> _tags = [
    'Food was hot 🔥',
    'Super fast delivery 🛵',
    'Polite driver 😊',
    'Great packaging 📦',
    'Delicious taste 😋',
    'Followed instructions ✨',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rate Your Experience', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Celebration Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              child: const Icon(Icons.celebration, color: AppColors.primary, size: 54),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Delivered Successfully!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              'Enjoy your delicious meal from ${widget.order.restaurantName}!',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            // Restaurant Rating Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [AppColors.softShadow]),
              child: Column(
                children: [
                  Text('How was the food from ${widget.order.restaurantName}?', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        icon: Icon(
                          star <= _restaurantRating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppColors.starYellow,
                          size: 36,
                        ),
                        onPressed: () => setState(() => _restaurantRating = star),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Driver Rating Card
            if (widget.order.driver != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [AppColors.softShadow]),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(widget.order.driver!.avatarUrl, width: 36, height: 36, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Text('Rate Driver ${widget.order.driver!.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          icon: Icon(
                            star <= _driverRating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: AppColors.starYellow,
                            size: 36,
                          ),
                          onPressed: () => setState(() => _driverRating = star),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Feedback Tag Chips
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [AppColors.softShadow]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('What made your experience great?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        selectedColor: AppColors.primarySoft,
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Leave a comment for chef and delivery hero...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Submit Feedback & Earn 50 Pts',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for rating! 50 Points Added to Wallet. ⭐'), backgroundColor: AppColors.successGreen),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
