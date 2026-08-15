import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../mock/mock_data.dart';
import '../services/supabase_service.dart';

class AppStateProvider extends ChangeNotifier {
  // Current Logged-in User Profile (Dynamic, starts clean for new users)
  UserProfile _user = UserProfile(
    id: 'user_${DateTime.now().millisecondsSinceEpoch}',
    fullName: 'New User',
    email: 'user@example.com',
    phone: '',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
    walletBalance: 0.0,
    loyaltyPoints: 0,
  );

  bool _isLoggedIn = false;
  bool _hasCompletedOnboarding = false;
  UserRole _currentRole = UserRole.customer;
  String _securityPin = '1234';
  final String _adminPasscode = 'ADMIN9999';
  Timer? _orderSimulationTimer;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding || _isLoggedIn;
  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  // Multi-Resto & Multi-Driver Active Session State
  Restaurant? _activeMerchantRestaurant;
  DeliveryDriver? _activeDriverSession;

  // Real Multi-Restaurant Credentials Database (Multi-Resto)
  final Map<String, Map<String, dynamic>> _registeredRestaurants = {
    'RESTO101': {
      'pin': '5555',
      'restaurant': Restaurant(
        id: 'resto_1',
        name: 'Haware Gourmet Burger Lab',
        logoUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        coverUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800',
        cuisines: ['Gourmet Burgers', 'American', 'Fast Food'],
        rating: 4.9,
        reviewCount: 382,
        deliveryTimeMinutes: 15,
        deliveryFee: 1.99,
        minOrder: 10.0,
        address: 'Shop 4, Haware Grand Heritage, Sector 21',
        isOpen: true,
      ),
    },
    'RESTO102': {
      'pin': '6666',
      'restaurant': Restaurant(
        id: 'resto_2',
        name: 'Woodfire Napoli Pizzeria',
        logoUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
        coverUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800',
        cuisines: ['Authentic Italian', 'Woodfire Pizza', 'Pasta'],
        rating: 4.8,
        reviewCount: 294,
        deliveryTimeMinutes: 20,
        deliveryFee: 2.49,
        minOrder: 12.0,
        address: 'Haware Centurion Mall, Sector 19',
        isOpen: true,
      ),
    },
    'RESTO103': {
      'pin': '7777',
      'restaurant': Restaurant(
        id: 'resto_3',
        name: 'Tokyo Ramen & Sushi Bar',
        logoUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
        coverUrl: 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=800',
        cuisines: ['Japanese', 'Sushi', 'Ramen & Bowls'],
        rating: 4.9,
        reviewCount: 512,
        deliveryTimeMinutes: 25,
        deliveryFee: 2.99,
        minOrder: 15.0,
        address: 'Sector 15, Kharghar Food Street',
        isOpen: true,
      ),
    },
  };

  // Real Multi-Driver Credentials Database (Multi-Driver)
  final Map<String, Map<String, dynamic>> _registeredDrivers = {
    'HERO01': {
      'pin': '7777',
      'driver': DeliveryDriver(
        id: 'drv_01',
        name: 'Rahul Sharma',
        phone: '+91 98201 11223',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        rating: 4.9,
        totalDeliveries: 342,
        vehicleModel: 'Honda Activa 6G (Black)',
        licensePlate: 'MH-43-AK-9821',
        isOnline: true,
        currentLatitude: 19.0330,
        currentLongitude: 73.0290,
      ),
    },
    'HERO02': {
      'pin': '8888',
      'driver': DeliveryDriver(
        id: 'drv_02',
        name: 'Vikram Singh',
        phone: '+91 98202 33445',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        rating: 4.8,
        totalDeliveries: 189,
        vehicleModel: 'TVS Jupiter (Grey)',
        licensePlate: 'MH-43-BM-4412',
        isOnline: true,
        currentLatitude: 19.0345,
        currentLongitude: 73.0310,
      ),
    },
  };

  // User-scoped Delivery Addresses (Starts clean for new users)
  final List<DeliveryAddress> _addresses = [
    DeliveryAddress(
      id: 'addr_default',
      label: 'Home',
      fullAddress: 'Haware Splendor, Sector 20, Kharghar, Navi Mumbai',
      apartmentSuite: 'Flat 602, Tower 3',
      landmark: 'Near Central Park',
      latitude: 19.0335,
      longitude: 73.0295,
      isDefault: true,
    ),
  ];
  DeliveryAddress _selectedAddress = DeliveryAddress(
    id: 'addr_default',
    label: 'Home',
    fullAddress: 'Haware Splendor, Sector 20, Kharghar, Navi Mumbai',
    apartmentSuite: 'Flat 602, Tower 3',
    landmark: 'Near Central Park',
    latitude: 19.0335,
    longitude: 73.0295,
    isDefault: true,
  );

  // Catalog Data
  final List<FoodCategory> _categories = List.from(MockData.categories);
  final List<Restaurant> _restaurants = List.from(MockData.restaurants);
  final List<MenuItem> _menuItems = List.from(MockData.menuItems);

  // Cart & Orders (Clean for new users)
  final List<CartItem> _cartItems = [];
  PromotionVoucher? _appliedVoucher;
  final Set<String> _likedFoodIds = {};
  final Set<String> _likedRestaurantIds = {};

  // Clean Orders List (Starts empty for genuine users)
  final List<Order> _orders = [];

  // Notifications
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'notif_welcome',
      title: 'Welcome to HawareEats! 🍕',
      body: 'Get 30% OFF on your first gourmet order with voucher code HAWARE30.',
      timestamp: DateTime.now(),
      type: 'promo',
    ),
  ];

  AppStateProvider() {
    _initAuthSession();
  }

  void _initAuthSession() {
    final authUser = SupabaseService.currentAuthUser;
    if (authUser != null) {
      _isLoggedIn = true;
      final meta = authUser.userMetadata ?? {};
      _user = UserProfile(
        id: authUser.id,
        fullName: meta['full_name'] ?? authUser.email?.split('@')[0] ?? 'Haware User',
        email: authUser.email ?? 'user@example.com',
        phone: meta['phone'] ?? '',
        avatarUrl: meta['avatar_url'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
        walletBalance: 25.00,
        loyaltyPoints: 100,
      );
    }
  }

  // Getters
  UserProfile get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  UserRole get currentRole => _currentRole;
  String get adminPasscode => _adminPasscode;
  bool get isDriverOnline => _activeDriverSession?.isOnline ?? true;
  Restaurant? get activeMerchantRestaurant => _activeMerchantRestaurant ?? _restaurants.first;
  DeliveryDriver get driverProfile => _activeDriverSession ?? _registeredDrivers.values.first['driver'] as DeliveryDriver;

  List<DeliveryAddress> get addresses => _addresses;
  DeliveryAddress get selectedAddress => _selectedAddress;
  List<FoodCategory> get categories => _categories;
  List<Restaurant> get restaurants => _restaurants;
  List<MenuItem> get menuItems => _menuItems;
  List<CartItem> get cartItems => _cartItems;
  PromotionVoucher? get appliedVoucher => _appliedVoucher;
  Set<String> get likedFoodIds => _likedFoodIds;
  Set<String> get likedRestaurantIds => _likedRestaurantIds;
  List<Order> get orders => _orders;
  List<NotificationItem> get notifications => _notifications;
  // In-app Driver Chat Messages
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'msg_1',
      senderId: 'driver_01',
      senderName: 'Delivery Hero',
      message: "Hi! I've picked up your food from the kitchen and I am riding your way! 🛵",
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isFromUser: false,
    ),
  ];

  List<ChatMessage> get messages => _messages;

  void sendMessage(String text, {bool isFromUser = true}) {
    _messages.add(
      ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: isFromUser ? _user.id : 'driver_01',
        senderName: isFromUser ? _user.fullName : 'Delivery Hero',
        message: text,
        timestamp: DateTime.now(),
        isFromUser: isFromUser,
      ),
    );
    notifyListeners();
  }

  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartSubtotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get cartDeliveryFee => cartSubtotal > 20.0 ? 0.0 : (_cartItems.isEmpty ? 0.0 : 2.49);
  double get cartServiceFee => _cartItems.isEmpty ? 0.0 : 1.50;
  double get cartDiscount {
    if (_appliedVoucher == null || _cartItems.isEmpty) return 0.0;
    double discount = (cartSubtotal * (_appliedVoucher!.discountPercent / 100));
    if (_appliedVoucher!.maxDiscount != null && discount > _appliedVoucher!.maxDiscount!) {
      discount = _appliedVoucher!.maxDiscount!;
    }
    return discount;
  }
  double get cartTotal => (cartSubtotal + cartDeliveryFee + cartServiceFee - cartDiscount).clamp(0.0, double.infinity);

  // Authentication Handlers
  void setUserFromAuth({required String id, required String email, required String fullName, required String phone}) {
    _isLoggedIn = true;
    _user = UserProfile(
      id: id,
      fullName: fullName.isNotEmpty ? fullName : email.split('@')[0],
      email: email,
      phone: phone,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
      walletBalance: 25.00,
      loyaltyPoints: 100,
    );
    notifyListeners();
  }

  void updateUserProfile(UserProfile updated) {
    _user = updated;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentRole = UserRole.customer;
    _cartItems.clear();
    SupabaseService.signOut();
    notifyListeners();
  }

  // Multi-Resto Authentication
  bool authenticateRestaurant(String restoCode, String pin) {
    final key = restoCode.trim().toUpperCase();
    if (_registeredRestaurants.containsKey(key)) {
      final entry = _registeredRestaurants[key]!;
      if (entry['pin'] == pin.trim()) {
        _activeMerchantRestaurant = entry['restaurant'] as Restaurant;
        _currentRole = UserRole.restaurantOwner;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Multi-Driver Authentication
  bool authenticateDriver(String driverId, String pin) {
    final key = driverId.trim().toUpperCase();
    if (_registeredDrivers.containsKey(key)) {
      final entry = _registeredDrivers[key]!;
      if (entry['pin'] == pin.trim()) {
        _activeDriverSession = entry['driver'] as DeliveryDriver;
        _currentRole = UserRole.driver;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Super Admin Authentication
  bool authenticateSuperAdmin(String passcode) {
    if (passcode.trim() == _adminPasscode) {
      _currentRole = UserRole.admin;
      notifyListeners();
      return true;
    }
    return false;
  }

  void switchRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void setSecurityPin(String pin) {
    _securityPin = pin;
    notifyListeners();
  }

  bool verifySecurityPin(String pin) => _securityPin == pin;

  // Cart Operations
  void addToCart(
    MenuItem item, {
    int quantity = 1,
    String size = 'Regular',
    List<CustomizerOption> addOns = const [],
    List<SelectedCustomizer> customizers = const [],
    String instructions = '',
  }) {
    final existingIndex = _cartItems.indexWhere((c) => c.menuItem.id == item.id && c.selectedSize == size);
    if (existingIndex >= 0) {
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + quantity,
      );
    } else {
      _cartItems.add(
        CartItem(
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
          menuItem: item,
          quantity: quantity,
          selectedSize: size,
          selectedAddOns: addOns,
          selectedCustomizers: customizers,
          specialInstructions: instructions,
        ),
      );
    }
    notifyListeners();
  }

  void updateCartQuantity(String cartItemId, int newQty) {
    if (newQty <= 0) {
      _cartItems.removeWhere((c) => c.id == cartItemId);
    } else {
      final idx = _cartItems.indexWhere((c) => c.id == cartItemId);
      if (idx >= 0) {
        _cartItems[idx] = _cartItems[idx].copyWith(quantity: newQty);
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _appliedVoucher = null;
    notifyListeners();
  }

  bool applyVoucher(String code) {
    final v = MockData.vouchers.firstWhere(
      (voucher) => voucher.code.toUpperCase() == code.trim().toUpperCase(),
      orElse: () => MockData.vouchers.first,
    );
    _appliedVoucher = v;
    notifyListeners();
    return true;
  }

  void removeVoucher() {
    _appliedVoucher = null;
    notifyListeners();
  }

  // Address Management
  void addAddress(DeliveryAddress address) {
    if (address.isDefault) {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
      _selectedAddress = address;
    }
    _addresses.add(address);
    notifyListeners();
  }

  void selectAddress(DeliveryAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  // Order Placement
  Order placeOrder({required String paymentMethod, double driverTip = 2.0, double? tip}) {
    final effectiveTip = tip ?? driverTip;
    final newOrder = Order(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 'HE-${10000 + _orders.length + 1}',
      restaurant: _restaurants.first,
      items: List.from(_cartItems),
      subtotal: cartSubtotal,
      deliveryFee: cartDeliveryFee,
      serviceFee: cartServiceFee,
      discount: cartDiscount,
      driverTip: effectiveTip,
      totalAmount: cartTotal + effectiveTip,
      status: OrderStatus.placed,
      deliveryAddress: _selectedAddress,
      paymentMethod: paymentMethod,
      placedAt: DateTime.now(),
      estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 25)),
      driver: _registeredDrivers.values.first['driver'] as DeliveryDriver,
    );

    _orders.insert(0, newOrder);
    _cartItems.clear();
    _appliedVoucher = null;
    notifyListeners();

    // Start auto-progressing order lifecycle milestones
    startOrderSimulation(newOrder.id);

    return newOrder;
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx] = _orders[idx].copyWith(status: status);
      
      // Add dynamic live notifications
      String title = 'Order Update';
      String body = 'Your order is being processed.';
      if (status == OrderStatus.confirmed) {
        title = 'Order Confirmed! ✅';
        body = 'The kitchen has accepted your order and started cooking.';
      } else if (status == OrderStatus.preparing) {
        title = 'Kitchen is Cooking 👨‍🍳';
        body = 'Your gourmet meal is on the grill with fresh ingredients!';
      } else if (status == OrderStatus.readyForPickup) {
        title = 'Ready for Pickup 📦';
        body = 'Order packed and assigned to Delivery Hero.';
      } else if (status == OrderStatus.onTheWay) {
        title = 'Driver is On The Way! 🛵';
        body = 'Your Delivery Hero is riding to your address.';
      } else if (status == OrderStatus.delivered) {
        title = 'Order Delivered! 🎉';
        body = 'Enjoy your delicious meal! Please leave a review.';
      }

      _notifications.insert(
        0,
        NotificationItem(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          body: body,
          type: 'order',
          timestamp: DateTime.now(),
        ),
      );

      // Trigger vibrational feedback
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}

      notifyListeners();
    }
  }

  void startOrderSimulation(String orderId) {
    _orderSimulationTimer?.cancel();
    int step = 0;
    final statusMilestones = [
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.readyForPickup,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];

    _orderSimulationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (step >= statusMilestones.length) {
        timer.cancel();
        return;
      }
      updateOrderStatus(orderId, statusMilestones[step]);
      step++;
    });
  }

  void cancelOrder(String orderId, String reason) {
    _orderSimulationTimer?.cancel();
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx] = _orders[idx].copyWith(status: OrderStatus.cancelled);
      notifyListeners();
    }
  }

  // Favorites
  void toggleFavoriteFood(String foodId) {
    if (_likedFoodIds.contains(foodId)) {
      _likedFoodIds.remove(foodId);
    } else {
      _likedFoodIds.add(foodId);
    }
    notifyListeners();
  }

  void toggleFavoriteRestaurant(String restoId) {
    if (_likedRestaurantIds.contains(restoId)) {
      _likedRestaurantIds.remove(restoId);
    } else {
      _likedRestaurantIds.add(restoId);
    }
    notifyListeners();
  }

  void updateMenuItemStock(String itemId, bool inStock) {
    final idx = _menuItems.indexWhere((m) => m.id == itemId);
    if (idx >= 0) {
      _menuItems[idx] = _menuItems[idx].copyWith(isAvailable: inStock);
      notifyListeners();
    }
  }

  void toggleDriverOnline(bool online) {
    if (_activeDriverSession != null) {
      _activeDriverSession = _activeDriverSession!.copyWith(isOnline: online);
      notifyListeners();
    }
  }
}
