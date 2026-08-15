import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const referralCode = 'HAWARE-EATS2026';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Invite Friends', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.card_giftcard, size: 72, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Give \$10, Get \$10! 🎁',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Share your unique referral code with friends. When they place their first burger or pizza order, you both get \$10 wallet credit!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 28),
            // Referral Code Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppColors.softShadow],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Referral Code', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      SizedBox(height: 4),
                      Text(referralCode, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.primary)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Referral Code Copied to Clipboard! 📋'), backgroundColor: AppColors.successGreen),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Copy Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Share Link with Friends 🚀',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing invite link via WhatsApp/SMS...'), backgroundColor: AppColors.successGreen),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
