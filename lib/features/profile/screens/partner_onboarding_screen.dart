import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class PartnerOnboardingScreen extends StatefulWidget {
  final bool isDriver;

  const PartnerOnboardingScreen({super.key, this.isDriver = false});

  @override
  State<PartnerOnboardingScreen> createState() => _PartnerOnboardingScreenState();
}

class _PartnerOnboardingScreenState extends State<PartnerOnboardingScreen> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController(text: 'Honda Super Cub / Motorcycle');
  final TextEditingController _licenseController = TextEditingController(text: 'MH-43-2026-009821');

  bool _submitted = false;

  void _submit() {
    setState(() => _submitted = true);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _vehicleController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDriver = widget.isDriver;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isDriver ? 'Drive with HawareEats 🛵' : 'Partner with Us 👨‍🍳',
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _submitted
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.check, size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isDriver ? 'Driver Application Submitted!' : 'Merchant Application Received!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isDriver
                          ? 'Our logistics team will verify your driving license and vehicle registration within 24 hours. You will receive an SMS when your driver account is active.'
                          : 'Our merchant onboarding team will review your kitchen details, menu, and FSSAI certificate within 24-48 hours. Welcome to the HawareEats family!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Back to Account',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDriver ? Colors.teal.shade50 : Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDriver ? Colors.teal.shade200 : Colors.purple.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(isDriver ? Icons.delivery_dining : Icons.storefront, color: isDriver ? Colors.teal : Colors.purple, size: 36),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDriver ? 'Earn up to \$40/hour delivering food' : 'Grow your restaurant sales by 300%',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDriver ? Colors.teal.shade900 : Colors.purple.shade900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isDriver ? 'Flexible hours, instant daily payouts & 100% tips.' : 'Zero upfront fees, dedicated tablet dispatch & analytics.',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!isDriver) ...[
                    _buildLabel('Restaurant / Kitchen Name'),
                    TextField(
                      controller: _businessNameController,
                      decoration: _inputDecoration('e.g. Haware Gourmet Burger Lab', Icons.storefront),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Commercial Kitchen Address'),
                    TextField(
                      controller: _addressController,
                      decoration: _inputDecoration('Shop / Unit address, Street, Sector', Icons.location_on_outlined),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildLabel('Vehicle Model & Type'),
                    TextField(
                      controller: _vehicleController,
                      decoration: _inputDecoration('e.g. Honda Super Cub 125cc (Red)', Icons.two_wheeler),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Driving License Number'),
                    TextField(
                      controller: _licenseController,
                      decoration: _inputDecoration('e.g. MH-43-2026-009821', Icons.badge_outlined),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildLabel('Applicant Full Name'),
                  TextField(
                    controller: _ownerNameController,
                    decoration: _inputDecoration('Full legal name', Icons.person_outline),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Direct Contact Phone'),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('+91 98200 12345', Icons.phone_outlined),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: isDriver ? 'Submit Driver Application ➔' : 'Submit Restaurant Registration ➔',
                    backgroundColor: isDriver ? Colors.teal : Colors.purple,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}
