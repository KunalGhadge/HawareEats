import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class CancelOrderSheet extends StatefulWidget {
  final String orderId;

  const CancelOrderSheet({super.key, required this.orderId});

  @override
  State<CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<CancelOrderSheet> {
  String _selectedReason = 'Waiting too long for preparation';
  final List<String> _reasons = [
    'Waiting too long for preparation',
    'Ordered by mistake',
    'Wrong delivery address entered',
    'Changed my mind / Want other food',
    'Driver not moving on map',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
          const SizedBox(height: 18),
          const Text('Cancel Food Order?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 6),
          const Text(
            'Please select the reason for cancellation. Refunds are instantly credited to your HawareEats Wallet.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          for (var reason in _reasons)
            RadioListTile<String>(
              value: reason,
              groupValue: _selectedReason,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: Text(reason, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onChanged: (val) {
                if (val != null) setState(() => _selectedReason = val);
              },
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Keep Order',
                  isOutlined: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: CustomButton(
                  text: 'Confirm Cancel',
                  backgroundColor: AppColors.errorRed,
                  onPressed: () {
                    context.read<AppStateProvider>().cancelOrder(widget.orderId, _selectedReason);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order Cancelled. 100% Refund credited to Wallet.'), backgroundColor: AppColors.errorRed),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
