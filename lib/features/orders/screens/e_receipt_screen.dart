import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/custom_button.dart';

class EReceiptScreen extends StatelessWidget {
  final Order order;

  const EReceiptScreen({super.key, required this.order});

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
        title: const Text('E-Receipt', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt shared successfully!'), backgroundColor: AppColors.successGreen),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [AppColors.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Barcode Graphic Header
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('||| | | |||| || | || ||||| ||| | ||| |||| | |||', style: TextStyle(fontSize: 18, letterSpacing: 2, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Transaction ID: #${order.orderNumber}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Courier'),
              ),
              const SizedBox(height: 20),
              // Restaurant Logo & Name
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(order.restaurantLogo, width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
              Text(
                order.restaurantName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                order.restaurantAddress,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
              // Order Metadata
              _buildMetaRow('Date & Time', '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} • ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}'),
              _buildMetaRow('Payment Method', order.paymentMethod),
              _buildMetaRow('Delivery Address', order.deliveryAddress.fullAddress),
              _buildMetaRow('Order Status', order.status.name.toUpperCase()),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
              // Itemized List
              for (var it in order.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${it.quantity}x ${it.menuItem.name}', style: const TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w500)),
                      ),
                      Text('\$${it.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
              // Summary
              _buildMetaRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
              _buildMetaRow('Delivery Fee', '\$${order.deliveryFee.toStringAsFixed(2)}'),
              _buildMetaRow('Service Fee', '\$${order.serviceFee.toStringAsFixed(2)}'),
              if (order.discountAmount > 0)
                _buildMetaRow('Discount (${order.promoCode})', '-\$${order.discountAmount.toStringAsFixed(2)}', isGreen: true),
              if (order.tipAmount > 0)
                _buildMetaRow('Driver Tip', '+\$${order.tipAmount.toStringAsFixed(2)}'),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(thickness: 1.5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total Paid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Download PDF Invoice 📥',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice saved to Downloads folder! 📄'), backgroundColor: AppColors.successGreen),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isGreen ? AppColors.successGreen : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
