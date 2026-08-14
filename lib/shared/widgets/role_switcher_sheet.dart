import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state_provider.dart';

class RoleSwitcherSheet extends StatefulWidget {
  const RoleSwitcherSheet({super.key});

  @override
  State<RoleSwitcherSheet> createState() => _RoleSwitcherSheetState();
}

class _RoleSwitcherSheetState extends State<RoleSwitcherSheet> {
  final TextEditingController _pinController = TextEditingController();
  bool _pinError = false;

  void _showPinDialog(BuildContext context, UserRole role) {
    _pinController.clear();
    setState(() => _pinError = false);

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                role == UserRole.admin ? Icons.admin_panel_settings : Icons.lock_outline,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                role == UserRole.admin ? 'Admin Verification' : 'Partner Access PIN',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role == UserRole.admin
                    ? 'Enter the 4-digit Master Security PIN (Default: 1234) to unlock platform management.'
                    : 'Enter your 4-digit Security PIN (Default: 1234) to switch to this mode.',
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
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  errorText: _pinError ? 'Incorrect PIN. Try 1234' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
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
                final state = context.read<AppStateProvider>();
                if (state.verifySecurityPin(_pinController.text)) {
                  state.switchRole(role);
                  Navigator.pop(dialogCtx);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Switched to ${role.name.toUpperCase()} mode!'),
                      backgroundColor: AppColors.successGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  setDialogState(() => _pinError = true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Verify & Switch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final currentRole = appState.currentRole;

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
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Switch HawareEats Mode',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'Test the complete ecosystem in a single unified app seamlessly.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          _buildRoleOption(
            context,
            role: UserRole.customer,
            title: 'Customer Mode (Default)',
            subtitle: 'Browse 130+ screens, food customizers, cart, checkout & live tracking.',
            icon: Icons.fastfood_rounded,
            iconColor: AppColors.primary,
            isSelected: currentRole == UserRole.customer,
            onTap: () {
              appState.switchRole(UserRole.customer);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _buildRoleOption(
            context,
            role: UserRole.restaurantOwner,
            title: 'Restaurant Partner Mode',
            subtitle: 'Live kitchen display, incoming orders, stock toggle & daily revenue.',
            icon: Icons.storefront_rounded,
            iconColor: Colors.purple,
            isSelected: currentRole == UserRole.restaurantOwner,
            onTap: () => _showPinDialog(context, UserRole.restaurantOwner),
          ),
          const SizedBox(height: 12),
          _buildRoleOption(
            context,
            role: UserRole.driver,
            title: 'Delivery Driver Mode',
            subtitle: 'Go online, accept trips, turn-by-turn navigation & wallet tips.',
            icon: Icons.delivery_dining_rounded,
            iconColor: Colors.teal,
            isSelected: currentRole == UserRole.driver,
            onTap: () => _showPinDialog(context, UserRole.driver),
          ),
          const SizedBox(height: 12),
          _buildRoleOption(
            context,
            role: UserRole.admin,
            title: 'Super Admin Hub',
            subtitle: 'Add & manage restaurants, verify drivers & platform statistics.',
            icon: Icons.shield_rounded,
            iconColor: Colors.deepOrange,
            isSelected: currentRole == UserRole.admin,
            onTap: () => _showPinDialog(context, UserRole.admin),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.08) : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? iconColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? iconColor : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: iconColor, size: 20)
            else
              const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
