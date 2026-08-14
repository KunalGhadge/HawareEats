import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state_provider.dart';

class HiddenEnterprisePortalDialog extends StatefulWidget {
  const HiddenEnterprisePortalDialog({super.key});

  @override
  State<HiddenEnterprisePortalDialog> createState() => _HiddenEnterprisePortalDialogState();
}

class _HiddenEnterprisePortalDialogState extends State<HiddenEnterprisePortalDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _isUnlocked = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyMasterPin() {
    final pin = _pinController.text.trim();
    if (pin == '1234') {
      setState(() {
        _isUnlocked = true;
        _errorMessage = '';
      });
    } else {
      setState(() {
        _errorMessage = 'Invalid Enterprise Master Key. Access Denied.';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.security, color: Colors.redAccent, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enterprise Security Gateway', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Confidential Staff / Internal Role Testing', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!_isUnlocked) ...[
              const Text(
                'This portal is strictly restricted to verified HawareEats internal operations personnel, kitchen dispatch managers, and platform engineers.',
                style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 4, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Enter Master PIN',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 0),
                  filled: true,
                  fillColor: Colors.black26,
                  prefixIcon: const Icon(Icons.key, color: Colors.white54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _verifyMasterPin,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Authenticate 🔓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'Access Granted (Admin Superuser Mode)',
                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 14),
              _buildRoleOption(context, appState, UserRole.customer, 'Customer View (Default)', Icons.person, Colors.blue),
              const SizedBox(height: 10),
              _buildRoleOption(context, appState, UserRole.restaurantOwner, 'Kitchen Merchant Display (KDS)', Icons.storefront, Colors.purple),
              const SizedBox(height: 10),
              _buildRoleOption(context, appState, UserRole.driver, 'Driver Hero Dispatch Portal', Icons.delivery_dining, Colors.teal),
              const SizedBox(height: 10),
              _buildRoleOption(context, appState, UserRole.admin, 'Super Admin Control Center', Icons.admin_panel_settings, Colors.deepOrange),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Portal', style: TextStyle(color: Colors.white54)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(BuildContext context, AppStateProvider appState, UserRole role, String label, IconData icon, Color color) {
    final isSelected = appState.currentRole == role;
    return GestureDetector(
      onTap: () {
        appState.switchRole(role);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Switched to $label'), backgroundColor: color),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? color : Colors.white12, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
          ],
        ),
      ),
    );
  }
}
