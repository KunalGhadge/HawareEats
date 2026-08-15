import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/interactive_gps_map.dart';
import 'driver_contact_screen.dart';
import 'cancel_order_sheet.dart';
import 'delivery_review_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final currentOrder = appState.orders.firstWhere((o) => o.id == order.id, orElse: () => order);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Live Interactive Vector GPS Route Map View
          Positioned.fill(
            child: InteractiveGpsMap(
              height: double.infinity,
              isTrackingMode: true,
              destinationAddress: currentOrder.deliveryAddress.fullAddress,
            ),
          ),
          // Top Back & Order Number Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [AppColors.softShadow],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textDark),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [AppColors.softShadow],
                  ),
                  child: Text(
                    'Order #${currentOrder.orderNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => CancelOrderSheet(orderId: currentOrder.id),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [AppColors.softShadow],
                    ),
                    child: const Icon(Icons.more_vert, size: 18, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Sliding Order Status Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Color(0x18000000), blurRadius: 20, offset: Offset(0, -6)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Estimated Time Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estimated Delivery Time', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(
                            currentOrder.status == OrderStatus.delivered ? 'Delivered!' : '18 - 22 Mins',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: currentOrder.status == OrderStatus.delivered ? AppColors.successGreen : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusBadgeText(currentOrder.status),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 4-Stage Stepper
                  _buildStepper(currentOrder.status),
                  const SizedBox(height: 20),
                  // Driver Snippet
                  if (currentOrder.driver != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              currentOrder.driver!.avatarUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentOrder.driver!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                  '${currentOrder.driver!.vehicleModel} • ${currentOrder.driver!.licensePlate}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: AppColors.starYellow, size: 14),
                                    const SizedBox(width: 2),
                                    Text('${currentOrder.driver!.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Call Button
                          IconButton(
                            icon: const Icon(Icons.phone, color: AppColors.primary),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (ctx) => DriverContactScreen(driver: currentOrder.driver!, isCall: true)),
                              );
                            },
                          ),
                          // Chat Button
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (ctx) => DriverContactScreen(driver: currentOrder.driver!, isCall: false)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Delivery Completed CTA or Action
                  if (currentOrder.status == OrderStatus.delivered)
                    CustomButton(
                      text: 'Rate & Review Delivery ⭐',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (ctx) => DeliveryReviewScreen(order: currentOrder)),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusBadgeText(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'In Kitchen';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.onTheWay:
        return 'On The Way 🛵';
      case OrderStatus.delivered:
        return 'Delivered 🎉';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Widget _buildStepper(OrderStatus status) {
    int activeIndex = 1;
    if (status == OrderStatus.placed) activeIndex = 1;
    if (status == OrderStatus.confirmed) activeIndex = 2;
    if (status == OrderStatus.preparing || status == OrderStatus.readyForPickup) activeIndex = 3;
    if (status == OrderStatus.onTheWay) activeIndex = 4;
    if (status == OrderStatus.delivered) activeIndex = 5;

    final steps = ['Order Placed', 'Confirmed', 'Kitchen Prep', 'On The Way'];

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index < activeIndex;
        final isCurrent = index == activeIndex - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      color: index == 0 ? Colors.transparent : (isCompleted ? AppColors.primary : Colors.grey.shade300),
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.primary : (isCurrent ? AppColors.primaryLight : Colors.grey.shade300),
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      height: 4,
                      color: index == steps.length - 1 ? Colors.transparent : (isCompleted ? AppColors.primary : Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCompleted || isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted || isCurrent ? AppColors.textDark : AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
