import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import 'security_pin_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneOrEmail;
  final String fullName;

  const OTPVerificationScreen({
    super.key,
    required this.phoneOrEmail,
    required this.fullName,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _secondsRemaining = 55;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Default prefilled code 7-4-2-9 for quick testing
    _controllers[0].text = '7';
    _controllers[1].text = '4';
    _controllers[2].text = '2';
    _controllers[3].text = '9';

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 55);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 4-digit code.'), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => SecurityPinScreen(
          fullName: widget.fullName,
          phoneOrEmail: widget.phoneOrEmail,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                child: const Icon(Icons.mark_email_read_outlined, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                'OTP Code Verification 🔒',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              Text(
                'We have sent a 4-digit verification code to\n${widget.phoneOrEmail}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 36),
              // 4 OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 62,
                    height: 68,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              // Resend Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the code? ", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  if (_secondsRemaining > 0)
                    Text('Resend in ${_secondsRemaining}s', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13))
                  else
                    GestureDetector(
                      onTap: _startTimer,
                      child: const Text('Resend Code', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline)),
                    ),
                ],
              ),
              const SizedBox(height: 36),
              CustomButton(
                text: 'Verify & Continue ➔',
                onPressed: _verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
