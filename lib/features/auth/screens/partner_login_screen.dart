import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../profile/screens/partner_onboarding_screen.dart';

class PartnerLoginScreen extends StatefulWidget {
  final bool initialIsDriver;

  const PartnerLoginScreen({super.key, this.initialIsDriver = false});

  @override
  State<PartnerLoginScreen> createState() => _PartnerLoginScreenState();
}

class _PartnerLoginScreenState extends State<PartnerLoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Restaurant Controllers
  final TextEditingController _restoIdController = TextEditingController();
  final TextEditingController _restoPinController = TextEditingController();

  // Driver Controllers
  final TextEditingController _driverIdController = TextEditingController();
  final TextEditingController _driverPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIsDriver ? 1 : 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _restoIdController.dispose();
    _restoPinController.dispose();
    _driverIdController.dispose();
    _driverPinController.dispose();
    super.dispose();
  }

  void _loginRestaurant() {
    final id = _restoIdController.text.trim();
    final pin = _restoPinController.text.trim();
    if (id.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Restaurant ID and Kitchen PIN.'), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    final appState = context.read<AppStateProvider>();
    if (appState.authenticateRestaurant(id, pin)) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authenticated as ${appState.activeMerchantRestaurant?.name}! 👨‍🍳'), backgroundColor: Colors.purple),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Restaurant ID or Kitchen PIN. Access Denied.'), backgroundColor: AppColors.errorRed),
      );
    }
  }

  void _loginDriver() {
    final id = _driverIdController.text.trim();
    final pin = _driverPinController.text.trim();
    if (id.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Driver Hero ID and Security PIN.'), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    final appState = context.read<AppStateProvider>();
    if (appState.authenticateDriver(id, pin)) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back ${appState.driverProfile.name}! 🛵'), backgroundColor: Colors.teal),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Driver ID or Security PIN. Access Denied.'), backgroundColor: AppColors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Partner Staff Gateway', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: 'Restaurant Kitchen'),
            Tab(icon: Icon(Icons.delivery_dining), text: 'Delivery Rider'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Restaurant Login Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.purple.shade200)),
                  child: const Row(
                    children: [
                      Icon(Icons.kitchen, color: Colors.purple, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Multi-Kitchen Access: Log in with your assigned restaurant credentials to manage live kitchen orders and menu stock.',
                          style: TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Restaurant ID / Merchant Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _restoIdController,
                  decoration: InputDecoration(
                    hintText: 'e.g. RESTO101, RESTO102',
                    prefixIcon: const Icon(Icons.tag, color: Colors.purple),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Kitchen Staff PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _restoPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '4-digit Kitchen PIN',
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.purple),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Access Kitchen Display (KDS) 👨‍🍳',
                  backgroundColor: Colors.purple,
                  onPressed: _loginRestaurant,
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => PartnerOnboardingScreen(isDriver: false)));
                    },
                    child: const Text('Not registered yet? Apply to partner with HawareEats', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          // Driver Login Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.teal.shade200)),
                  child: const Row(
                    children: [
                      Icon(Icons.two_wheeler, color: Colors.teal, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Multi-Driver Access: Log in with your Rider Hero ID to go online, accept dispatch trips, and track daily earnings.',
                          style: TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Driver Hero ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverIdController,
                  decoration: InputDecoration(
                    hintText: 'e.g. HERO01, HERO02',
                    prefixIcon: const Icon(Icons.badge_outlined, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Security PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '4-digit Driver PIN',
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Access Driver Dispatch 🛵',
                  backgroundColor: Colors.teal,
                  onPressed: _loginDriver,
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => PartnerOnboardingScreen(isDriver: true)));
                    },
                    child: const Text('New rider? Apply to drive with HawareEats', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
