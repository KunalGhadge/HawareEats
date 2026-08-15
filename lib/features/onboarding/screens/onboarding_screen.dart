import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/state/app_state_provider.dart';
import '../models/onboarding_item.dart';
import '../../auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _items = const [
    OnboardingItem(
      title: 'Wide Selection',
      description: 'More than 400 gourmet restaurants & local food heroes in Haware.',
      imagePath: 'assets/images/onboarding_1.jpg',
    ),
    OnboardingItem(
      title: 'Lightning Delivery',
      description: 'Gourmet hot meals delivered in 15-25 minutes straight to your doorstep.',
      imagePath: 'assets/images/onboarding_2.jpg',
    ),
    OnboardingItem(
      title: 'Live GPS Tracking',
      description: 'Watch your delivery hero ride on the live interactive GPS map.',
      imagePath: 'assets/images/onboarding_3.jpg',
    ),
    OnboardingItem(
      title: 'Special Offers',
      description: 'Enjoy exclusive up to 50% discounts & free delivery vouchers daily.',
      imagePath: 'assets/images/onboarding_4.jpg',
    ),
  ];

  void _onNextPressed() {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onSkipPressed() {
    _finishOnboarding();
  }

  void _finishOnboarding() {
    context.read<AppStateProvider>().completeOnboarding();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (ctx) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset('assets/images/app_logo.png', width: 28, height: 28, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'HawareEats',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _onSkipPressed,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image Container with Card Styling & Shadow
                        Container(
                          width: double.infinity,
                          height: 320,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              AppColors.cardShadow,
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              item.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.white,
                                child: const Icon(Icons.fastfood, size: 80, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Description
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Section: Dots + Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.indicatorActive
                              : AppColors.indicatorInactive,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Next / Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textWhite,
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _currentIndex == _items.length - 1 ? 'Get Started 🚀' : 'Next ➔',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
