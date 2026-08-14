import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state_provider.dart';

class AdminLoginDialog extends StatefulWidget {
  const AdminLoginDialog({super.key});

  @override
  State<AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<AdminLoginDialog> {
  final TextEditingController _passcodeController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  void _verifyAdmin() {
    final appState = context.read<AppStateProvider>();
    final pass = _passcodeController.text.trim();
    if (appState.authenticateSuperAdmin(pass)) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Super Admin Superuser Authenticated! ⚡'), backgroundColor: Colors.deepOrange),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid Super Admin Passcode. Access Denied.';
        _passcodeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF13131A),
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
                  decoration: BoxDecoration(color: Colors.deepOrange.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.deepOrange, size: 26),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Super Admin Control', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Platform Command Center', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Enter the confidential HawareEats Super Admin Master Passcode to access platform finances, analytics, and merchant operations.',
              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passcodeController,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Enter Admin Passcode',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 0),
                filled: true,
                fillColor: Colors.black38,
                prefixIcon: const Icon(Icons.lock, color: Colors.deepOrange, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _verifyAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Unlock Admin Hub ⚡', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
