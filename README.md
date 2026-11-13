# 🏙️ New Horizon Properties – Premium Real Estate Platform

<div align="center">

**Discover Properties. Explore Investments. Experience Luxury.**

A modern, luxury-inspired real estate application built with Flutter, combining property discovery, investment calculations, VIP viewing requests, and agency management in one platform.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-orange?style=for-the-badge)
![Design](https://img.shields.io/badge/Design-Luxury%20UI-D4AF37?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

</div>

---

## 📖 Overview

**New Horizon Properties** is a premium real estate application designed to transform the way users explore properties and interact with real estate services.

Developed using Flutter and Dart, the application combines an elegant luxury interface with practical property discovery, investment analysis, client services, and agency management features.

The platform offers two major experiences:

- **Client Portal:** Explore properties, view detailed listings, calculate estimated investment returns, and request VIP property viewings.
- **Staff Portal:** Manage property inventory, monitor dashboard metrics, organize leads, track deals, and access team management features.

Its signature dark luxury design, gold accents, responsive layouts, and smooth animations create a modern real estate experience.

## ✨ Key Features

### 🏡 1. Property Discovery

- Browse residential and commercial properties.
- Explore houses, villas, plazas, shops, and plots.
- Discover properties for sale and rent.
- Explore off-plan property opportunities.
- Filter listings by property category and transaction type.
- View detailed property information.
- Display property prices in PKR.

### 📊 2. Investment & ROI Calculator

An interactive property investment calculator designed to help users explore potential investment scenarios.

Features include:

- Gross rental yield calculations.
- Net rental yield calculations.
- Cash-on-cash return estimates.
- DSCR calculations.
- Property price adjustment.
- Down payment percentage.
- Interest rate and loan tenure inputs.
- Rental yield and annual appreciation inputs.
- Custom Canvas-based property growth charts.
- Investment projections for up to 20 years.

**Disclaimer:** All financial calculations are estimates based on entered assumptions. They do not guarantee returns or constitute financial advice.

### ✈️ 3. VIP Property Viewing

- Request private property viewings.
- Private jet charter option.
- City helicopter transfer option.
- Luxury chauffeur transport option.
- Guest count management.
- Custom date and time selection.
- Viewing request status interface.

### 👔 4. Executive Leadership Directory

- Executive leadership profiles.
- Senior advisor directory.
- Professional team presentation.
- Advisory booking and communication entry points.

### 🧑‍💼 5. Staff & Agency Management

A dedicated staff portal with management-oriented features.

- Admin, Manager, and Agent role concepts.
- Staff dashboard.
- Sales volume metrics.
- Active property inventory overview.
- Lead pipeline tracking.
- Conversion rate metrics.
- Property listing management.
- Create and edit property listings.
- Publish and archive listing interfaces.
- Lead management.
- Kanban-style deal pipeline.
- Staff onboarding and approval interface.
- Team directory.
- Client view preview mode.

### 🔐 6. Authentication & Security Interface

- Separate client and staff login experiences.
- Login and registration interfaces.
- Biometric authentication UI.
- Password strength indicator.
- Account recovery interface.
- Security question validation flow.
- OTP simulation interface.

**Important:** These authentication and recovery interfaces require proper backend integration and server-side verification before production use. UI functionality alone does not provide production-grade security.

## 🎨 Design System

New Horizon Properties follows a premium dark luxury visual identity.

| Element | Color |
|---|---|
| Main Background | `#0F0F10` |
| Card Surface | `#18181A` |
| Secondary Surface | `#1C1C1F` |
| Gold Accent | `#F7A10A` |
| Warm Peach | `#FFB57D` |

### UI/UX Highlights

- Modern luxury-inspired interface.
- Dark charcoal backgrounds.
- Premium gold and warm peach accents.
- Glass-inspired visual elements.
- Smooth micro-animations.
- Animated tab transitions.
- Custom Canvas-based charts.
- Responsive layouts.
- Reusable Flutter widgets.

### Responsive Experience

- Mobile bottom navigation.
- Tablet split-screen layouts.
- Desktop side navigation.
- Adaptive screen breakpoints.

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform development |
| Dart | Programming language |
| Material Design | UI foundation |
| Custom Canvas | Investment growth charts |
| Responsive Utilities | Adaptive layouts |
| Dart Data Models | Property and staff data |
| In-Memory Stores | Local prototype data |
| Custom Widgets | Reusable UI components |

## 🏗️ Project Architecture

```text
lib/
├── data/
│   ├── listings.dart
│   ├── staff_data.dart
│   └── stores.dart
├── screens/
│   ├── auth_screen.dart
│   ├── biometric_sheet.dart
│   ├── home_screen.dart
│   ├── hub_tab.dart
│   ├── listing_detail_screen.dart
│   ├── roi_engine_screen.dart
│   ├── staff_screen.dart
│   └── vip_viewing_screen.dart
├── staff/
│   ├── dashboard_tab.dart
│   ├── listing_editor_screen.dart
│   ├── listings_tab.dart
│   ├── pipeline_tab.dart
│   ├── staff_shell.dart
│   └── team_tab.dart
├── theme/
│   └── app_colors.dart
├── utils/
│   ├── app_nav.dart
│   ├── helpers.dart
│   └── responsive.dart
└── widgets/
    ├── action_button.dart
    ├── animated_tab_switch.dart
    ├── auth_field.dart
    ├── gradient_button.dart
    ├── listing_card.dart
    ├── press_scale.dart
    └── staff_ui.dart
```

## 🚀 Installation & Setup

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Flutter and Dart extensions

Check your Flutter environment:

```bash
flutter doctor
flutter --version
```

### 1. Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/new_horizon.git
cd new_horizon
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run Application

For Android or connected devices:

```bash
flutter run
```

For Chrome:

```bash
flutter run -d chrome
```

Check available devices:

```bash
flutter devices
```

## 📦 Build Application

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### Web Build

```bash
flutter build web --release
```

## 🎨 Assets & Splash Screen

The project uses the following logo asset:

```text
assets/images/logo.png
```

If launcher icon and native splash screen packages are configured in `pubspec.yaml`, generate assets using:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## 📸 Screenshots & Application Preview

Add actual application screenshots in a `screenshots/` directory.

| Property Hub | Property Details |
|:---:|:---:|
| Add Property Hub Screenshot | Add Property Details Screenshot |

| Investment Calculator | VIP Viewing |
|:---:|:---:|
| Add ROI Screenshot | Add VIP Viewing Screenshot |

| Staff Dashboard | Deal Pipeline |
|:---:|:---:|
| Add Dashboard Screenshot | Add Pipeline Screenshot |

## 🧪 Code Quality

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## 🔧 Current Implementation & Production Readiness

The current project includes property datasets, in-memory stores, user-interface flows, and management screens.

For a production-ready real estate platform, the following integrations should be considered:

- Secure backend and database.
- Persistent property listings.
- Real client and staff authentication.
- Server-side role-based permissions.
- Cloud image storage.
- Live property search and filtering.
- Real VIP booking and transport integrations.
- Persistent lead and deal management.
- Verified financial calculation logic.
- Notification system.
- Privacy policy and terms of service.

## 🗺️ Future Enhancements

- [ ] Backend and database integration.
- [ ] Live property listings.
- [ ] Google Maps integration.
- [ ] Advanced property search.
- [ ] Real-time booking management.
- [ ] Secure staff authentication.
- [ ] Push notifications.
- [ ] Cloud image storage.
- [ ] Automated testing.

## 🤝 Contributions

Contributions, suggestions, and improvements are welcome.

1. Fork the repository.
2. Create a new feature branch.
3. Implement your changes.
4. Test your implementation.
5. Submit a pull request.

## 📄 License

This project is licensed under the MIT License.

---

<div align="center">

**Built with ❤️ using Flutter & Dart**

*New Horizon Properties — Redefining the Real Estate Experience.*

</div>
