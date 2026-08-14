import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/state/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/interactive_gps_map.dart';
import 'add_edit_address_screen.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final addresses = appState.addresses;
    final selectedId = appState.selectedAddress.id;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Delivery Addresses',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const AddEditAddressScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Interactive Vector GPS Map Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: InteractiveGpsMap(
              height: 170,
              isTrackingMode: false,
              destinationAddress: appState.selectedAddress.fullAddress,
            ),
          ),
          // Address List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final addr = addresses[index];
                final isSelected = addr.id == selectedId;

                return GestureDetector(
                  onTap: () {
                    appState.selectAddress(addr);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: const [AppColors.softShadow],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primarySoft : AppColors.inputBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconForLabel(addr.label),
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    addr.label,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                                  ),
                                  if (addr.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(6)),
                                      child: const Text('DEFAULT', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                addr.fullAddress,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                              ),
                              if (addr.apartmentSuite.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  addr.apartmentSuite,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                              if (addr.landmark.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Landmark: ${addr.landmark}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            if (isSelected)
                              const Icon(Icons.check_circle, color: AppColors.primary, size: 22)
                            else
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.textMuted, size: 18),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (ctx) => AddEditAddressScreen(addressToEdit: addr)),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom Add Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              text: '+ Add New Delivery Address',
              isOutlined: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const AddEditAddressScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
      case 'office':
        return Icons.work_rounded;
      case 'apartment':
        return Icons.apartment_rounded;
      case 'parents':
        return Icons.family_restroom_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
}
