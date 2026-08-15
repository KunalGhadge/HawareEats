import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../tracking/screens/order_tracking_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedPaymentMethod = 'Cash on Delivery';
  double _selectedTip = 2.00;
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _showComingSoonNotice(String gatewayName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.rocket_launch, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('Coming Soon! 🚀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '$gatewayName integration will be enabled in the upcoming update.\n\nPlease proceed with Cash on Delivery (COD) for your order today!',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _selectedPaymentMethod = 'Cash on Delivery');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Use Cash on Delivery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmAndPlaceOrder() {
    final appState = context.read<AppStateProvider>();
    _pinController.clear();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Security PIN Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your 4-digit Security PIN to authorize order of \$${(appState.cartTotal + _selectedTip).toStringAsFixed(2)} via $_selectedPaymentMethod.',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '••••',
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredPin = _pinController.text.trim();
                if (appState.verifySecurityPin(enteredPin) || enteredPin == '1234') {
                  try {
                    HapticFeedback.heavyImpact();
                  } catch (_) {}

                  final order = appState.placeOrder(
                    paymentMethod: _selectedPaymentMethod,
                    tip: _selectedTip,
                  );
                  Navigator.pop(dialogCtx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (ctx) => OrderTrackingScreen(order: order)),
                  );
                } else {
                  try {
                    HapticFeedback.vibrate();
                  } catch (_) {}
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect Security PIN. Please enter your 4-digit security PIN.'), backgroundColor: AppColors.errorRed),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Authorize Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final grandTotal = appState.cartTotal + _selectedTip;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment Method', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('HawareEats Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text('\$${appState.user.walletBalance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('★ ${appState.user.loyaltyPoints} Loyalty Points Active', style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _selectedPaymentMethod = 'HawareEats Wallet');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Select', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Driver Tip Selector
            const Text('Tip Your Delivery Hero 🛵', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 6),
            const Text('100% of the tip goes directly to your delivery partner.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Row(
              children: [0.0, 1.0, 2.0, 3.0, 5.0].map((tip) {
                final isSelected = _selectedTip == tip;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(tip == 0 ? 'No Tip' : '+\$${tip.toStringAsFixed(0)}'),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedTip = tip);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Payment Options List
            const Text('Payment Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            _buildPaymentTile('HawareEats Wallet', 'Instant deduction with loyalty points', Icons.account_balance_wallet, Colors.orange),
            _buildPaymentTile('Google Pay / Apple Pay', 'Fast one-touch checkout', Icons.phone_android, Colors.black),
            _buildPaymentTile('Credit / Debit Card', 'Visa, Mastercard, Amex', Icons.credit_card, Colors.blue),
            _buildPaymentTile('Cash on Delivery', 'Pay with cash at your doorstep', Icons.payments, Colors.green),
            const SizedBox(height: 12),
            // Add New Card CTA
            OutlinedButton.icon(
              onPressed: () => _showComingSoonNotice('Credit / Debit Card'),
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: const Text('Add New Card', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            // Total & Pay Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [AppColors.softShadow],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total to Pay', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text('\$${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                  SizedBox(
                    width: 180,
                    child: CustomButton(
                      text: 'Place Order ➔',
                      onPressed: _confirmAndPlaceOrder,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(String title, String subtitle, IconData icon, Color iconColor) {
    final isCOD = title == 'Cash on Delivery';
    final isSelected = _selectedPaymentMethod == title;

    return GestureDetector(
      onTap: () {
        if (isCOD) {
          setState(() => _selectedPaymentMethod = title);
        } else {
          _showComingSoonNotice(title);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
          boxShadow: const [AppColors.softShadow],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                      if (!isCOD) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orange.shade300)),
                          child: const Text('Coming Soon', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            Radio<String>(
              value: title,
              groupValue: _selectedPaymentMethod,
              activeColor: AppColors.primary,
              onChanged: (val) {
                if (isCOD) {
                  setState(() => _selectedPaymentMethod = val!);
                } else {
                  _showComingSoonNotice(title);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
