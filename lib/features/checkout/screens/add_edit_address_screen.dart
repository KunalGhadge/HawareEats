import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/interactive_gps_map.dart';

class AddEditAddressScreen extends StatefulWidget {
  final DeliveryAddress? addressToEdit;

  const AddEditAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  late TextEditingController _addressController;
  late TextEditingController _aptController;
  late TextEditingController _landmarkController;
  late TextEditingController _notesController;
  String _selectedLabel = 'Home';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final a = widget.addressToEdit;
    _addressController = TextEditingController(text: a?.fullAddress ?? 'Haware Splendor, Sector 20, Kharghar');
    _aptController = TextEditingController(text: a?.apartmentSuite ?? '');
    _landmarkController = TextEditingController(text: a?.landmark ?? 'Near Central Park');
    _notesController = TextEditingController(text: a?.deliveryNotes ?? 'Please ring bell upon arrival.');
    _selectedLabel = a?.label ?? 'Home';
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _aptController.dispose();
    _landmarkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your complete address.'), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    final newAddr = DeliveryAddress(
      id: widget.addressToEdit?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: _selectedLabel,
      fullAddress: _addressController.text.trim(),
      apartmentSuite: _aptController.text.trim(),
      landmark: _landmarkController.text.trim(),
      deliveryNotes: _notesController.text.trim(),
      latitude: 19.0335,
      longitude: 73.0295,
      isDefault: _isDefault,
    );

    final appState = context.read<AppStateProvider>();
    appState.addAddress(newAddr);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address Saved Successfully! 📍'), backgroundColor: AppColors.successGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          widget.addressToEdit != null ? 'Edit Address' : 'Add New Address',
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Vector GPS Map Pinpoint Selector
            InteractiveGpsMap(
              height: 180,
              isTrackingMode: false,
              destinationAddress: _addressController.text,
            ),
            const SizedBox(height: 20),
            // Address Label Chips
            const Text('Save Address As', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 10),
            Row(
              children: ['Home', 'Work', 'Apartment', 'Parents', 'Other'].map((label) {
                final isSelected = _selectedLabel == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedLabel = label);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Full Address
            _buildFieldLabel('Complete Street Address / Society'),
            TextField(
              controller: _addressController,
              decoration: _inputDecoration('e.g. Haware Splendor, Sector 20', Icons.map_outlined),
            ),
            const SizedBox(height: 14),
            // Apartment / Suite
            _buildFieldLabel('Flat / House / Suite Number'),
            TextField(
              controller: _aptController,
              decoration: _inputDecoration('e.g. Flat 602, Tower 3', Icons.apartment_outlined),
            ),
            const SizedBox(height: 14),
            // Landmark
            _buildFieldLabel('Nearby Landmark (Optional)'),
            TextField(
              controller: _landmarkController,
              decoration: _inputDecoration('e.g. Near Central Park Gate 2', Icons.flag_outlined),
            ),
            const SizedBox(height: 14),
            // Delivery Instructions
            _buildFieldLabel('Delivery Instructions for Hero'),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: _inputDecoration('e.g. Please leave package at front door, ring bell...', Icons.edit_note_outlined),
            ),
            const SizedBox(height: 14),
            // Default Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [AppColors.softShadow]),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text('Set as Default Delivery Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Save Delivery Address 📍',
              onPressed: _save,
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
