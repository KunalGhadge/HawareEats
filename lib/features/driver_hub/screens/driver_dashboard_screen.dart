import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _deliveryStep = 0; // 0: Accept, 1: Pick up from restaurant, 2: Arrive at customer, 3: Completed

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isOnline = appState.isDriverOnline;
    final driver = appState.driverProfile;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.delivery_dining, color: Colors.teal),
            SizedBox(width: 8),
            Text('Haware Driver Hero', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.exit_to_app, color: Colors.teal, size: 18),
            label: const Text('Exit', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
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
            // Driver Online Switch & Wallet Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Colors.teal.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.teal.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(driver.avatarUrl, width: 44, height: 44, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driver.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('${driver.vehicleModel} • ${driver.licensePlate}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: isOnline,
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.successGreen,
                        onChanged: (val) => appState.toggleDriverOnline(val),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: Colors.white24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDriverMetric("Today's Earnings", '\$84.50'),
                      Container(width: 1, height: 30, color: Colors.white24),
                      _buildDriverMetric('Completed Trips', '14 Trips'),
                      Container(width: 1, height: 30, color: Colors.white24),
                      _buildDriverMetric('Driver Rating', '4.9★'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Live Trip Dispatch Simulator
            const Text('Active Delivery Trip Dispatch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [AppColors.softShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Text('TRIP #HE-98214', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      const Text('+\$7.50 Total Payout', style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.w800, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Pickup & Dropoff Stepper
                  _buildTripLocation(Icons.storefront, 'Pickup: Haware Burger Kitchen', 'Shop 4, Haware Grand Heritage', Colors.purple),
                  Container(
                    margin: const EdgeInsets.only(left: 19),
                    height: 24,
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                  _buildTripLocation(Icons.location_on, 'Dropoff: Customer Address', 'Flat 602, Haware Splendor, Sector 20', AppColors.primary),
                  const SizedBox(height: 20),
                  // Action Stepper Button
                  CustomButton(
                    text: _getDriverActionText(_deliveryStep),
                    backgroundColor: Colors.teal,
                    onPressed: () {
                      setState(() {
                        if (_deliveryStep < 3) {
                          _deliveryStep++;
                        } else {
                          _deliveryStep = 0;
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_getDriverSuccessToast(_deliveryStep)), backgroundColor: AppColors.successGreen),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _getDriverActionText(int step) {
    switch (step) {
      case 0:
        return 'Accept Delivery Trip 🛵';
      case 1:
        return 'Confirm Food Picked Up from Kitchen 📦';
      case 2:
        return 'Arrived at Customer & Complete Delivery 🎉';
      default:
        return 'Ready for Next Delivery Request ⚡';
    }
  }

  String _getDriverSuccessToast(int step) {
    switch (step) {
      case 1:
        return 'Trip Accepted! Head to Restaurant.';
      case 2:
        return 'Food Picked Up! Navigating to Customer.';
      case 3:
        return 'Delivery Completed! \$7.50 Credited to Wallet. 🎉';
      default:
        return 'Online for next trip!';
    }
  }

  Widget _buildDriverMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildTripLocation(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
