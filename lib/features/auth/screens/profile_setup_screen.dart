import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../main_shell.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String? fullName;
  final String? phoneOrEmail;
  final bool isInitialSetup;

  const ProfileSetupScreen({
    super.key,
    this.fullName,
    this.phoneOrEmail,
    this.isInitialSetup = false,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  String _selectedGender = 'Male';
  String _avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400';

  final List<String> _avatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=400',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400',
  ];

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    final user = appState.user;

    _nameController = TextEditingController(text: widget.fullName ?? user.fullName);
    _nicknameController = TextEditingController(text: user.nickname.isNotEmpty ? user.nickname : '');
    _emailController = TextEditingController(text: widget.phoneOrEmail?.contains('@') == true ? widget.phoneOrEmail : user.email);
    _phoneController = TextEditingController(text: widget.phoneOrEmail?.contains('@') == false ? widget.phoneOrEmail : user.phone);
    _dobController = TextEditingController(text: user.dateOfBirth.isNotEmpty ? user.dateOfBirth : '2000-01-01');
    _selectedGender = user.gender;
    _avatarUrl = user.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    DateTime initial = DateTime(2000, 1, 1);
    try {
      if (_dobController.text.isNotEmpty) {
        initial = DateTime.parse(_dobController.text);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white, surface: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _saveProfile() {
    final appState = context.read<AppStateProvider>();
    final updated = appState.user.copyWith(
      fullName: _nameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      gender: _selectedGender,
      avatarUrl: _avatarUrl,
    );

    appState.updateUserProfile(updated);

    // Save
    if (widget.isInitialSetup) {
      appState.completeOnboarding();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => const MainShell()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome to HawareEats! Profile setup complete 🎉'), backgroundColor: AppColors.successGreen),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully! ✨'), backgroundColor: AppColors.successGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.isInitialSetup
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          widget.isInitialSetup ? 'Fill Your Profile 👤' : 'Edit Profile',
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Selector
            Center(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(_avatarUrl, width: 100, height: 100, fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Avatar picker sheet
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Choose Avatar Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: _avatars.map((url) {
                                    final isSelected = _avatarUrl == url;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() => _avatarUrl = url);
                                        Navigator.pop(ctx);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 3),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(30),
                                          child: Image.network(url, width: 56, height: 56, fit: BoxFit.cover),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, boxShadow: [AppColors.softShadow]),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Full Name
            _buildFieldLabel('Full Name'),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Enter your full name', Icons.person_outline),
            ),
            const SizedBox(height: 16),
            // Nickname
            _buildFieldLabel('Nickname'),
            TextField(
              controller: _nicknameController,
              decoration: _inputDecoration('e.g. Alex / Foodie', Icons.badge_outlined),
            ),
            const SizedBox(height: 16),
            // Email
            _buildFieldLabel('Email Address'),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('name@example.com', Icons.email_outlined),
            ),
            const SizedBox(height: 16),
            // Phone
            _buildFieldLabel('Phone Number'),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('+91 98200 12345', Icons.phone_outlined),
            ),
            const SizedBox(height: 16),
            // Date of Birth & Gender
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Date of Birth'),
                      GestureDetector(
                        onTap: _pickDateOfBirth,
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _dobController,
                            decoration: _inputDecoration('Select Date of Birth', Icons.calendar_today_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Gender'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGender,
                            isExpanded: true,
                            items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 14)))).toList(),
                            onChanged: (val) => setState(() => _selectedGender = val ?? 'Male'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: widget.isInitialSetup ? 'Complete Setup ➔' : 'Save Changes ✨',
              onPressed: _saveProfile,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
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
