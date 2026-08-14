import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/admin_login_dialog.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/profile_setup_screen.dart';
import '../../auth/screens/partner_login_screen.dart';
import '../../checkout/screens/location_picker_screen.dart';
import '../../checkout/screens/payment_methods_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/invite_friends_screen.dart';
import '../screens/support_chat_screen.dart';
import '../screens/partner_onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _adminTapCount = 0;
  DateTime? _lastTapTime;

  void _onVersionTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!).inMilliseconds > 1200) {
      _adminTapCount = 1;
    } else {
      _adminTapCount++;
    }
    _lastTapTime = now;

    if (_adminTapCount >= 10) {
      _adminTapCount = 0;
      showDialog(
        context: context,
        builder: (ctx) => const AdminLoginDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final user = appState.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Account', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Header Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [AppColors.softShadow],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          user.avatarUrl,
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Container(
                            width: 68,
                            height: 68,
                            color: AppColors.primarySoft,
                            child: const Icon(Icons.person, color: AppColors.primary, size: 36),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const ProfileSetupScreen(isInitialSetup: false)),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.accentYellow, borderRadius: BorderRadius.circular(6)),
                              child: const Text('VIP GOLD', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        if (user.phone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(user.phone, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note_outlined, color: AppColors.primary, size: 26),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const ProfileSetupScreen(isInitialSetup: false)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Menu Items List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppColors.softShadow],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    iconColor: Colors.blueAccent,
                    title: 'Edit Profile Details',
                    subtitle: 'Name, phone & avatar photo',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const ProfileSetupScreen(isInitialSetup: false)),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.blue,
                    title: 'Saved Delivery Addresses',
                    subtitle: '${appState.addresses.length} locations configured',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const LocationPickerScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.credit_card_outlined,
                    iconColor: Colors.green,
                    title: 'Payment Methods & Wallet',
                    subtitle: '\$${user.walletBalance.toStringAsFixed(2)} balance active',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const PaymentMethodsScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.card_giftcard_outlined,
                    iconColor: Colors.orange,
                    title: 'Invite Friends & Earn \$10',
                    subtitle: 'Share your referral code',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const InviteFriendsScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.storefront_outlined,
                    iconColor: Colors.purple,
                    title: 'Partner with Us (Restaurants)',
                    subtitle: 'List your commercial kitchen on HawareEats',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const PartnerOnboardingScreen(isDriver: false)),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.delivery_dining_outlined,
                    iconColor: Colors.teal,
                    title: 'Drive with HawareEats (Riders)',
                    subtitle: 'Deliver orders & earn daily payouts',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const PartnerOnboardingScreen(isDriver: true)),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.business_center_outlined,
                    iconColor: Colors.indigo,
                    title: 'Staff & Partner Login',
                    subtitle: 'Kitchen KDS & Driver Rider login door',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const PartnerLoginScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.support_agent_outlined,
                    iconColor: Colors.teal,
                    title: '24/7 Live Support Chat',
                    subtitle: 'Talk to HawareEats customer advocate',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const SupportChatScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    iconColor: AppColors.errorRed,
                    title: 'Sign Out',
                    subtitle: 'Log out of this device',
                    isLast: true,
                    onTap: () {
                      appState.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Confidential Enterprise Version Footer with 10-tap Super Admin listener
            GestureDetector(
              onTap: _onVersionTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'HawareEats v1.0.0 (Production Build)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Secured with 256-bit TLS & Supabase Cloud',
                      style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ),
        if (!isLast) const Divider(height: 1, indent: 68),
      ],
    );
  }
}
