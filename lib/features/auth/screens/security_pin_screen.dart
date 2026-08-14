import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import 'profile_setup_screen.dart';

class SecurityPinScreen extends StatefulWidget {
  final String fullName;
  final String phoneOrEmail;

  const SecurityPinScreen({
    super.key,
    required this.fullName,
    required this.phoneOrEmail,
  });

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  String _pin = '';
  final int _pinLength = 4;

  void _onKeypadTap(String value) {
    if (_pin.length < _pinLength) {
      setState(() => _pin += value);
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _savePinAndContinue() {
    if (_pin.length < _pinLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 4-digit Security PIN.'), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    context.read<AppStateProvider>().setSecurityPin(_pin);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => ProfileSetupScreen(
          fullName: widget.fullName,
          phoneOrEmail: widget.phoneOrEmail,
          isInitialSetup: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              child: const Icon(Icons.shield_outlined, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Set Security PIN 🔑',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'This PIN protects your wallet balance, checkout authorizations, and account security.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
            ),
            const SizedBox(height: 32),
            // 4 PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                final isFilled = index < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: isFilled ? AppColors.primary : Colors.grey.shade400, width: 2),
                  ),
                );
              }),
            ),
            const Spacer(),
            // Numeric Keypad
            Container(
              padding: const EdgeInsets.fromLTRB(36, 10, 36, 10),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: 14),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: 14),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 72, height: 56),
                      _buildKeypadButton('0'),
                      SizedBox(
                        width: 72,
                        height: 56,
                        child: IconButton(
                          icon: const Icon(Icons.backspace_outlined, size: 26, color: AppColors.textDark),
                          onPressed: _onBackspace,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: CustomButton(
                text: 'Save PIN & Continue ➔',
                onPressed: _savePinAndContinue,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) => _buildKeypadButton(key)).toList(),
    );
  }

  Widget _buildKeypadButton(String key) {
    return Container(
      width: 72,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.softShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onKeypadTap(key),
          child: Center(
            child: Text(
              key,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
        ),
      ),
    );
  }
}
