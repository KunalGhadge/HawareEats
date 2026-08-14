# 🍔 HawareEats — Next-Gen Gourmet Food Delivery Platform

<p align="center">
  <img src="assets/images/app_logo.png" width="120" height="120" alt="HawareEats Logo" style="border-radius: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.15);"/>
</p>

<p align="center">
  <b>Ultra-fast, hyper-local food discovery and instant gourmet delivery app built with Flutter and Supabase.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-v3.27+-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-v3.6+-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Supabase-Realtime_Auth_%26_DB-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" />
  <img src="https://img.shields.io/badge/Platforms-Android_|_iOS_|_Web-FF6347?style=for-the-badge" />
  <img src="https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white" />
</p>

---

## 📖 Product Overview

**HawareEats** is a comprehensive, production-grade food delivery application crafted to deliver a seamless multi-sided experience for Customers, Multi-Kitchen Restaurants, Delivery Heroes, and Platform Administrators — all within a unified, high-performance Flutter codebase.

### ✨ Key Features

* 🛍️ **Customer Experience Hub**:
  - **Dynamic Food Discovery**: 12+ categories (Burgers, Pizza, Asian Bowls, Desserts, Beverages, Mexican).
  - **Deep Customization Engine**: Real-time pricing calculations for custom sizes, toppings, cheeses, and notes.
  - **Basket & Smart Discounts**: Instant coupon validation (`HAWARE30`, `FREESHIP`), multi-tier discount capping, and live tipping.
  - **Clean State & Dynamic Profiles**: Zero pre-filled fake data. Fresh accounts start with clean, user-scoped profiles and empty order histories.

* 🗺️ **Interactive Vector GPS Engine**:
  - **Smooth Pan & Zoom Canvas**: Interactive map with street-level road topology and landmark pins.
  - **Animated Rider Marker**: Real-time delivery hero navigation simulating motorcycle motion along city road waypoints.
  - **Live Delivery HUD**: Speedometer (`32 km/h`), pulsing GPS radius ring, and live ETA calculations.

* 👨‍🍳 **Multi-Tenant Restaurant Portal (KDS)**:
  - Multi-restaurant credentials for individual restaurant kitchens.
  - Real-time Kitchen Display System with order acceptance, preparation state triggers, and live menu inventory management.

* 🛵 **Multi-Tenant Driver Dispatch**:
  - Separate Rider logins with individual hero IDs and security PINs.
  - Online/Offline toggle, live dispatch requests, turn-by-turn route tracking, and daily earnings breakdown.

* 🛡️ **Concealed Super Admin Control**:
  - Activated by **10 rapid taps** on the Version footer with Master Passcode authentication (`ADMIN9999`).
  - Total gross platform revenue metrics, platform-wide restaurant/driver management, and CRUD controls.

---

## 🏗️ Architecture & Tech Stack

```
lib/
├── core/
│   ├── app_colors.dart         # Design tokens & signature orange color system
│   ├── app_theme.dart          # Light & Dark typography, shapes, and inputs
│   ├── models/                 # Strongly-typed domain models (copyWith, immutability)
│   ├── services/               # Supabase backend authentication & client service
│   └── state/                  # AppStateProvider (Cart, Orders, Addresses, Roles)
├── features/
│   ├── auth/                   # Sign In, Sign Up, OTP Verification, Security PIN, Partner Login
│   ├── catalog/                # Food categories, dish search, detail bottom sheets
│   ├── cart/                   # Basket overview, voucher redemptions, cost calculations
│   ├── checkout/               # Payment gateways, tipping, interactive address picker
│   ├── orders/                 # Live & past order history with re-order workflows
│   ├── tracking/               # Live GPS driver navigation map & driver in-app chat
│   ├── profile/                # User profile settings, payment cards, partner applications
│   ├── restaurant_hub/         # Kitchen Display System (KDS) & stock management
│   ├── driver_hub/             # Rider dispatch, trip acceptances, earnings analytics
│   └── admin/                  # Super Admin platform revenues & tenant management
└── shared/
    └── widgets/                # Interactive GPS Map, Custom Buttons, Rating Bars, Dialogs
```

* **Frontend**: Flutter (Material 3 with custom Glassmorphism & micro-animations).
* **State Management**: `Provider` with reactive state synchronization.
* **Backend**: Supabase (PostgreSQL 15, Auth, Row Level Security, Storage).
* **Map Engine**: Custom Vector Graphics Canvas (`CustomPainter`) with physics-based interpolation.
* **CI/CD**: GitHub Actions automated Android APK releases.

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>=3.27.0`)
* [Dart SDK](https://dart.dev/get-dart) (`>=3.6.0`)
* Java 17 (for Android release builds)
* A Supabase project

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/haware-eats.git
cd haware-eats
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Supabase Backend
1. Open your **Supabase Dashboard** ➔ **SQL Editor**.
2. Run the SQL script from [`supabase_schema.sql`](supabase_schema.sql) to create all tables, triggers, and Row Level Security policies.
3. Configure your API keys in `lib/core/services/supabase_service.dart` or via environment parameters:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

### 4. Run the Application
* **Web**:
  ```bash
  flutter run -d chrome
  ```
* **Android (Device/Emulator)**:
  ```bash
  flutter run -d android
  ```

---

## 📦 Automated APK Building (GitHub Actions)

This repository includes a pre-configured CI/CD workflow (`.github/workflows/build_apk.yml`).

Every time you push code to `main` or `master`:
1. GitHub Actions automatically installs Flutter and builds **Release APKs**.
2. Both **Universal APK** (`app-release.apk`) and **Split ABI APKs** (`arm64-v8a`, `armeabi-v7a`, `x86_64`) are generated and uploaded directly to your GitHub repository's **Actions Artifacts** tab for download!

To build manually on your local workstation:
```bash
flutter build apk --release
```
The output APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🔐 Default Multi-Tenant Credentials (Demo / Testing)

| Role | Identifier / ID | Passcode / PIN | Description |
| :--- | :--- | :--- | :--- |
| **Super Admin** | 10 rapid taps on Version footer | `ADMIN9999` | Global admin controls & platform revenue |
| **Restaurant 1** | `RESTO101` | `5555` | Haware Gourmet Burger Lab (KDS) |
| **Restaurant 2** | `RESTO102` | `6666` | Woodfire Napoli Pizzeria (KDS) |
| **Restaurant 3** | `RESTO103` | `7777` | Tokyo Ramen & Sushi Bar (KDS) |
| **Driver 1** | `HERO01` | `7777` | Rahul Sharma (Honda Activa 6G) |
| **Driver 2** | `HERO02` | `8888` | Vikram Singh (TVS Jupiter) |

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License
This project is proprietary and confidential. Developed for the **HawareEats** platform.
