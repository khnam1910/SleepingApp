# Organic Sleep 🌙

Organic Sleep is a modern, high-precision Flutter application designed to help users optimize their sleep cycles and wake up feeling refreshed. Unlike standard alarm apps, Organic Sleep integrates native system services to ensure reliability even in extreme background conditions.

## ✨ Key Features

### 📅 Smart Sleep Scheduling
- **Cycle-based Planning:** Calculate the best time to wake up or go to sleep based on 90-minute sleep cycles.
- **Dynamic Calculation:** Choose between "I will sleep" or "I will wake up" modes to find your optimal schedule.

### ⏰ High-Precision Alarms
- **Native Integration:** Leverages Android's `AlarmManager` and `AlarmClock` modes for precise triggering that bypasses aggressive battery optimizations.
- **Exact Alarms:** Guaranteed to ring at the exact second, even when the phone is in "Doze" mode or the app is killed.

### 🔔 Intelligent Notifications
- **Pre-Alarm Reminders:** Receive a gentle nudge 5 minutes before your alarm rings, with quick actions to skip today's wake-up.
- **Bedtime Reminders:** Get notified 3 minutes before your scheduled bedtime to help you unwind.
- **"Skip Today" Logic:** Dismiss an upcoming alarm for just one day with a professional UI indicator. The switch stays **ON**, ensuring you don't forget to wake up tomorrow.

### 🛡️ Background Resilience
- **Persistent Services:** Optimized background isolates handle notification interactions without requiring the app to be open.
- **Full Screen Intents:** Notifications can wake the screen and show high-priority banners even when locked.

### ☁️ Cloud Synchronization
- **Firebase Backend:** Securely sync your sleep profiles and alarm history across devices using Firestore and Firebase Auth.
- **Social Integration:** Support for Facebook Login.

## 🛠️ Technical Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** [BLoC / Cubit](https://pub.dev/packages/flutter_bloc) for predictable state transitions.
- **Backend:** 
  - Firebase Auth (Email/Password, Facebook)
  - Cloud Firestore (Real-time data sync)
  - Firebase Cloud Functions
- **Native Services:** 
  - `flutter_local_notifications` for high-priority alerts.
  - `alarm` for system-level sound triggers.
  - `timezone` for absolute scheduling precision.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest stable version)
- Java 17+
- Android Studio / VS Code

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/sleeping_app_flutter.git
   cd sleeping_app_flutter
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Place your `google-services.json` in `android/app/`.
   - Place your `GoogleService-Info.plist` in `ios/Runner/`.

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📝 Important Notes for Developers
- **Android Permissions:** This app requires `USE_EXACT_ALARM` and `SCHEDULE_EXACT_ALARM` for reliability.
- **Battery Optimization:** For 100% accuracy on devices like Xiaomi/Samsung, users may need to set the app to "No restrictions" in battery settings.

---
*Developed with ❤️ for better sleep.*
