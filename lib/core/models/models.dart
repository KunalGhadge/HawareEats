enum UserRole {
  customer,
  restaurantOwner,
  driver,
  admin,
}

enum OrderStatus {
  placed,
  confirmed,
  preparing,
  readyForPickup,
  onTheWay,
  delivered,
  cancelled,
}

class UserProfile {
  final String id;
  final String phone;
  final String email;
  final String fullName;
  final String nickname;
  final String avatarUrl;
  final String dateOfBirth;
  final String gender;
  final double walletBalance;
  final int loyaltyPoints;
  final bool isVip;
  final UserRole activeRole;
  final List<UserRole> permittedRoles;

  UserProfile({
    required this.id,
    required this.phone,
    required this.email,
    required this.fullName,
    this.nickname = '',
    this.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
    this.dateOfBirth = '1998-05-14',
    this.gender = 'Male',
    this.walletBalance = 145.50,
    this.loyaltyPoints = 1250,
    this.isVip = true,
    this.activeRole = UserRole.customer,
    this.permittedRoles = const [UserRole.customer, UserRole.restaurantOwner, UserRole.driver, UserRole.admin],
  });

  UserProfile copyWith({
    String? id,
    String? phone,
    String? email,
    String? fullName,
    String? nickname,
    String? avatarUrl,
    String? dateOfBirth,
    String? gender,
    double? walletBalance,
    int? loyaltyPoints,
    bool? isVip,
    UserRole? activeRole,
    List<UserRole>? permittedRoles,
  }) {
    return UserProfile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      walletBalance: walletBalance ?? this.walletBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      isVip: isVip ?? this.isVip,
      activeRole: activeRole ?? this.activeRole,
      permittedRoles: permittedRoles ?? this.permittedRoles,
    );
  }
}

class DeliveryAddress {
  final String id;
  final String label; // Home, Work, Apartment, Other
  final String fullAddress;
  final String apartmentSuite;
  final String landmark;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String deliveryNotes;

  DeliveryAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.apartmentSuite = '',
    this.landmark = '',
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.deliveryNotes = '',
  });

  DeliveryAddress copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? apartmentSuite,
    String? landmark,
    double? latitude,
    double? longitude,
    bool? isDefault,
    String? deliveryNotes,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      apartmentSuite: apartmentSuite ?? this.apartmentSuite,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
    );
  }
}

class FoodCategory {
  final String id;
  final String name;
  final String slug;
  final String iconEmoji;
  final String imageUrl;
  final int itemCount;

  const FoodCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconEmoji,
    required this.imageUrl,
    this.itemCount = 24,
  });
}

class Restaurant {
  final String id;
  final String name;
  final String slug;
  final String logoUrl;
  final String bannerUrl;
  final String description;
  final List<String> cuisines;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final String priceTier; // $, $$, $$$
  final int avgPrepTimeMinutes;
  final double deliveryFee;
  final double minOrderAmount;
  final bool isOpen;
  final bool isFeatured;
  final String discountTag;

  Restaurant({
    required this.id,
    required this.name,
    this.slug = '',
    required this.logoUrl,
    String? coverUrl,
    this.bannerUrl = 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800',
    this.description = '',
    required this.cuisines,
    this.address = 'Haware Splendor, Sector 20',
    this.latitude = 19.0335,
    this.longitude = 73.0295,
    this.rating = 4.8,
    this.reviewCount = 120,
    this.priceTier = '\$\$',
    int? deliveryTimeMinutes,
    this.avgPrepTimeMinutes = 20,
    this.deliveryFee = 2.49,
    double? minOrder,
    this.minOrderAmount = 10.0,
    this.isOpen = true,
    this.isFeatured = false,
    this.discountTag = 'Free Delivery',
  });
}

class CustomizerOption {
  final String id;
  final String name;
  final double priceDelta;
  final bool isDefault;

  const CustomizerOption({
    required this.id,
    required this.name,
    required this.priceDelta,
    this.isDefault = false,
  });
}

class CustomizerGroup {
  final String id;
  final String title;
  final int minSelection;
  final int maxSelection;
  final bool isRequired;
  final List<CustomizerOption> options;

  const CustomizerGroup({
    required this.id,
    required this.title,
    this.minSelection = 0,
    this.maxSelection = 1,
    this.isRequired = false,
    required this.options,
  });
}

class MenuItem {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String categoryId;
  final String name;
  final String description;
  final String imageUrl;
  final double basePrice;
  final double? discountedPrice;
  final int calories;
  final int prepTimeMinutes;
  final bool isVeg;
  final bool isBestSeller;
  final bool isAvailable;
  final double rating;
  final List<String> ingredients;
  final List<CustomizerGroup> customizerGroups;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.basePrice,
    this.discountedPrice,
    this.calories = 450,
    this.prepTimeMinutes = 15,
    this.isVeg = false,
    this.isBestSeller = false,
    this.isAvailable = true,
    this.rating = 4.8,
    this.ingredients = const ['Fresh Beef', 'Cheddar Cheese', 'Crisp Lettuce', 'Brioche Bun'],
    this.customizerGroups = const [],
  });

  double get effectivePrice => discountedPrice ?? basePrice;

  MenuItem copyWith({
    String? id,
    String? restaurantId,
    String? restaurantName,
    String? categoryId,
    String? name,
    String? description,
    String? imageUrl,
    double? basePrice,
    double? discountedPrice,
    int? calories,
    int? prepTimeMinutes,
    bool? isVeg,
    bool? isBestSeller,
    bool? isAvailable,
    double? rating,
    List<String>? ingredients,
    List<CustomizerGroup>? customizerGroups,
  }) {
    return MenuItem(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      basePrice: basePrice ?? this.basePrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      calories: calories ?? this.calories,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      isVeg: isVeg ?? this.isVeg,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      ingredients: ingredients ?? this.ingredients,
      customizerGroups: customizerGroups ?? this.customizerGroups,
    );
  }
}

class SelectedCustomizer {
  final String groupTitle;
  final String optionName;
  final double priceDelta;

  SelectedCustomizer({
    required this.groupTitle,
    required this.optionName,
    required this.priceDelta,
  });
}

class CartItem {
  final String id;
  final MenuItem menuItem;
  int quantity;
  final List<SelectedCustomizer> selectedCustomizers;
  final String specialInstructions;
  final String selectedSize;
  final List<CustomizerOption> selectedAddOns;

  CartItem({
    required this.id,
    required this.menuItem,
    this.quantity = 1,
    this.selectedCustomizers = const [],
    this.specialInstructions = '',
    this.selectedSize = 'Regular',
    this.selectedAddOns = const [],
  });

  double get unitPrice {
    double total = menuItem.effectivePrice;
    for (var c in selectedCustomizers) {
      total += c.priceDelta;
    }
    for (var a in selectedAddOns) {
      total += a.priceDelta;
    }
    return total;
  }

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    String? id,
    MenuItem? menuItem,
    int? quantity,
    List<SelectedCustomizer>? selectedCustomizers,
    String? specialInstructions,
    String? selectedSize,
    List<CustomizerOption>? selectedAddOns,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      selectedCustomizers: selectedCustomizers ?? this.selectedCustomizers,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedAddOns: selectedAddOns ?? this.selectedAddOns,
    );
  }
}

class DeliveryDriver {
  final String id;
  final String name;
  final String phone;
  final String avatarUrl;
  final String vehicleType;
  final String vehicleModel;
  final String licensePlate;
  final double rating;
  final int totalTrips;
  final int totalDeliveries;
  final double currentLatitude;
  final double currentLongitude;
  final bool isOnline;

  DeliveryDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatarUrl,
    this.vehicleType = 'Motorcycle',
    required this.vehicleModel,
    required this.licensePlate,
    this.rating = 4.9,
    this.totalTrips = 320,
    this.totalDeliveries = 320,
    required this.currentLatitude,
    required this.currentLongitude,
    this.isOnline = true,
  });

  DeliveryDriver copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatarUrl,
    String? vehicleType,
    String? vehicleModel,
    String? licensePlate,
    double? rating,
    int? totalTrips,
    int? totalDeliveries,
    double? currentLatitude,
    double? currentLongitude,
    bool? isOnline,
  }) {
    return DeliveryDriver(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      licensePlate: licensePlate ?? this.licensePlate,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String restaurantId;
  final String restaurantName;
  final String restaurantLogo;
  final String restaurantAddress;
  final Restaurant? restaurant;
  final DeliveryDriver? driver;
  final DeliveryAddress deliveryAddress;
  OrderStatus status;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double discountAmount;
  final double discount;
  final double tipAmount;
  final double driverTip;
  final double totalAmount;
  final String promoCode;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime placedAt;
  final DateTime estimatedDeliveryTime;
  final String? cancellationReason;

  Order({
    required this.id,
    required this.orderNumber,
    this.restaurantId = 'resto_1',
    this.restaurantName = 'Haware Gourmet Burger Lab',
    this.restaurantLogo = '',
    this.restaurantAddress = '',
    this.restaurant,
    this.driver,
    required this.deliveryAddress,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    this.discountAmount = 0.0,
    double? discount,
    this.tipAmount = 0.0,
    double? driverTip,
    required this.totalAmount,
    this.promoCode = '',
    required this.items,
    DateTime? createdAt,
    DateTime? placedAt,
    required this.estimatedDeliveryTime,
    this.cancellationReason,
  })  : discount = discount ?? discountAmount,
        driverTip = driverTip ?? tipAmount,
        createdAt = createdAt ?? DateTime.now(),
        placedAt = placedAt ?? DateTime.now();

  Order copyWith({
    String? id,
    String? orderNumber,
    String? restaurantId,
    String? restaurantName,
    String? restaurantLogo,
    String? restaurantAddress,
    Restaurant? restaurant,
    DeliveryDriver? driver,
    DeliveryAddress? deliveryAddress,
    OrderStatus? status,
    String? paymentMethod,
    double? subtotal,
    double? deliveryFee,
    double? serviceFee,
    double? discountAmount,
    double? tipAmount,
    double? totalAmount,
    String? promoCode,
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? estimatedDeliveryTime,
    String? cancellationReason,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantLogo: restaurantLogo ?? this.restaurantLogo,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      restaurant: restaurant ?? this.restaurant,
      driver: driver ?? this.driver,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      discountAmount: discountAmount ?? this.discountAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      promoCode: promoCode ?? this.promoCode,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}

class PromotionVoucher {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discountPercent;
  final double? maxDiscount;
  final double minOrder;
  final String expiryDate;

  const PromotionVoucher({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercent,
    this.maxDiscount,
    this.minOrder = 15.0,
    required this.expiryDate,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final String messageText;
  final DateTime timestamp;
  final bool isFromMe;
  final bool isFromUser;

  ChatMessage({
    required this.id,
    this.senderId = 'user',
    this.senderName = 'You',
    this.senderRole = 'user',
    String? message,
    String? messageText,
    required this.timestamp,
    bool isFromMe = false,
    bool isFromUser = false,
  })  : message = message ?? messageText ?? '',
        messageText = messageText ?? message ?? '',
        isFromMe = isFromMe || isFromUser,
        isFromUser = isFromUser || isFromMe;
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type; // order, promo, account
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}
