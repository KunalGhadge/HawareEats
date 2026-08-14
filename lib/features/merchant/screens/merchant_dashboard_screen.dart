import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/state/app_state_provider.dart';

class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final menuItems = appState.menuItems;
    final orders = appState.orders;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.storefront, color: Colors.purple),
            SizedBox(width: 8),
            Text('Haware Kitchen Partner', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.exit_to_app, color: Colors.purple, size: 18),
            label: const Text('Exit', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: () {
              appState.switchRole(UserRole.customer);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Returned to Customer Mode'), backgroundColor: AppColors.primary),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade700, Colors.deepPurple.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Today's Gross Sales", style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('🟢 STORE ONLINE', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('\$482.50', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMetricPill('28 Orders Today'),
                      const SizedBox(width: 8),
                      _buildMetricPill('4.9★ Rating'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Live Incoming Orders / Kitchen Stepper
            const Text('Live Kitchen Display (KDS)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            if (orders.isEmpty)
              const Text('No incoming orders right now', style: TextStyle(color: AppColors.textMuted))
            else
              for (var order in orders.take(2))
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [AppColors.softShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Text(order.status.name.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (var it in order.items)
                        Text('${it.quantity}x ${it.menuItem.name}', style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Marked as Food Preparing in Kitchen! 👨‍🍳'), backgroundColor: AppColors.successGreen),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              child: const Text('Start Preparing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Notified Driver: Food Ready for Pickup! 🛵'), backgroundColor: AppColors.successGreen),
                                );
                              },
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.purple), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              child: const Text('Ready for Driver', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 24),
            // Menu Stock Availability Manager
            const Text('Menu Stock Manager (Instant Toggle)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 6),
            const Text('Tap toggle to mark dishes In-Stock or Sold-Out instantly for customers.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppColors.softShadow],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(item.imageUrl, width: 48, height: 48, fit: BoxFit.cover),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('\$${item.effectivePrice.toStringAsFixed(2)} • ${item.isAvailable ? "In Stock" : "Sold Out"}', style: TextStyle(color: item.isAvailable ? AppColors.successGreen : AppColors.errorRed, fontSize: 12)),
                    trailing: Switch(
                      value: item.isAvailable,
                      activeColor: Colors.purple,
                      onChanged: (val) {
                        appState.updateMenuItemStock(item.id, val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} is now ${val ? "IN STOCK" : "SOLD OUT"}'),
                            backgroundColor: val ? AppColors.successGreen : AppColors.errorRed,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
