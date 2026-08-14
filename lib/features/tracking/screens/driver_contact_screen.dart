import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/state/app_state_provider.dart';

class DriverContactScreen extends StatefulWidget {
  final DeliveryDriver driver;
  final bool isCall;

  const DriverContactScreen({super.key, required this.driver, this.isCall = false});

  @override
  State<DriverContactScreen> createState() => _DriverContactScreenState();
}

class _DriverContactScreenState extends State<DriverContactScreen> {
  final TextEditingController _msgController = TextEditingController();
  bool _isMuted = false;
  bool _isSpeaker = true;

  final List<String> _quickChips = [
    'I am waiting outside 🚪',
    'Please ring the door bell 🔔',
    'Leave the food at the front desk 📦',
    'Take your time and ride safe 🛵',
  ];

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCall) {
      // Voice Call UI
      return Scaffold(
        backgroundColor: const Color(0xFF1E232A),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'HawareEats In-App VoIP Call',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              // Driver Avatar & Name
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(widget.driver.avatarUrl, width: 120, height: 120, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.driver.name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Delivery Hero • ${widget.driver.vehicleModel}',
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
                    child: const Text('01:24 • Connected', style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              // Call Controls
              Padding(
                padding: const EdgeInsets.all(36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute
                    IconButton(
                      iconSize: 32,
                      icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                      onPressed: () => setState(() => _isMuted = !_isMuted),
                    ),
                    // End Call
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(color: AppColors.errorRed, shape: BoxShape.circle),
                        child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                      ),
                    ),
                    // Speaker
                    IconButton(
                      iconSize: 32,
                      icon: Icon(_isSpeaker ? Icons.volume_up : Icons.volume_off, color: Colors.white),
                      onPressed: () => setState(() => _isSpeaker = !_isSpeaker),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // In-App Chat UI
    final appState = context.watch<AppStateProvider>();
    final messages = appState.messages;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(widget.driver.avatarUrl, width: 36, height: 36, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.driver.name, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.bold)),
                const Text('Online • On Delivery', style: TextStyle(color: AppColors.successGreen, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: AppColors.primary),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (ctx) => DriverContactScreen(driver: widget.driver, isCall: true)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Action Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _quickChips.map((chip) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(chip, style: const TextStyle(fontSize: 11, color: AppColors.textDark)),
                      backgroundColor: AppColors.inputBackground,
                      onPressed: () {
                        appState.sendMessage(chip);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Chat Messages List
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text('Message ${widget.driver.name}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return Align(
                        alignment: msg.isFromMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isFromMe ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [AppColors.softShadow],
                          ),
                          child: Text(
                            msg.messageText,
                            style: TextStyle(color: msg.isFromMe ? Colors.white : AppColors.textDark, fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Input Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [AppColors.softShadow]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                  onPressed: () {
                    if (_msgController.text.trim().isNotEmpty) {
                      appState.sendMessage(_msgController.text.trim());
                      _msgController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
