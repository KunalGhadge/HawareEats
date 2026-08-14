import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/state/app_state_provider.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final vouchers = MockData.vouchers;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Promotions & Vouchers', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          final v = vouchers[index];
          final isApplied = appState.appliedVoucher?.id == v.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isApplied ? AppColors.successGreen : Colors.transparent, width: 2),
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
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${v.discountPercent.toInt()}% DISCOUNT',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    Text(v.expiryDate, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(v.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(v.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Code Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: Text(
                        v.code,
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13, color: AppColors.textDark),
                      ),
                    ),
                    // Action Button
                    ElevatedButton(
                      onPressed: () {
                        if (isApplied) {
                          appState.removeVoucher();
                        } else {
                          appState.applyVoucher(v.code);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Voucher ${v.code} Applied to Basket! 🎟️'), backgroundColor: AppColors.successGreen),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApplied ? AppColors.errorRed : AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(isApplied ? 'Remove' : 'Apply to Basket', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
