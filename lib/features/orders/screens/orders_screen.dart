import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../screens/e_receipt_screen.dart';
import '../../tracking/screens/order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final orders = appState.orders;

    final activeOrders = orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList();
    final completedOrders = orders.where((o) => o.status == OrderStatus.delivered).toList();
    final cancelledOrders = orders.where((o) => o.status == OrderStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Orders', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: 'Active (${activeOrders.length})'),
            Tab(text: 'Completed (${completedOrders.length})'),
            Tab(text: 'Cancelled (${cancelledOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(activeOrders, isActive: true),
          _buildOrdersList(completedOrders, isCompleted: true),
          _buildOrdersList(cancelledOrders, isCancelled: true),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> list, {bool isActive = false, bool isCompleted = false, bool isCancelled = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              child: const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 54),
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No Active Orders Right Now' : (isCompleted ? 'No Completed Orders Yet' : 'No Cancelled Orders'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            const Text('When you place an order, track it live here!', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final order = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [AppColors.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Header
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(order.restaurantLogo, width: 44, height: 44, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(
                          'Order #${order.orderNumber} • ${order.items.length} items',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primarySoft : (isCompleted ? Colors.green.shade50 : Colors.red.shade50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppColors.primary : (isCompleted ? AppColors.successGreen : AppColors.errorRed),
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
              // Items Summary
              for (var it in order.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${it.quantity}x ${it.menuItem.name}', style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                      Text('\$${it.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 14),
              // Action Buttons
              Row(
                children: [
                  if (isActive)
                    Expanded(
                      child: CustomButton(
                        text: 'Track Order Live 🛵',
                        height: 44,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => OrderTrackingScreen(order: order)),
                          );
                        },
                      ),
                    )
                  else ...[
                    Expanded(
                      child: CustomButton(
                        text: 'View Receipt 📄',
                        isOutlined: true,
                        height: 44,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => EReceiptScreen(order: order)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Re-Order 🔁',
                        height: 44,
                        onPressed: () {
                          for (var it in order.items) {
                            context.read<AppStateProvider>().addToCart(it.menuItem, quantity: it.quantity, addOns: it.selectedAddOns, size: it.selectedSize);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Items reloaded into your Basket! 🛒'), backgroundColor: AppColors.successGreen),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
