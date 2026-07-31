# Implementation Plan: Fix Background Notifications (App Killed State)

The goal is to ensure notifications trigger reliably even when the app is completely closed or killed. This requires higher-level Android permissions and specific Activity configurations to wake the device.

## User Review Required

> [!CAUTION]
> On some devices (Xiaomi, Samsung, Oppo), you may still need to manually enable "Auto-start" and set Battery Optimization to "No restrictions" in the phone settings for 100% reliability, as these manufacturers often override standard Android behavior.

## Proposed Changes

### Android Configuration

#### [MODIFY] [AndroidManifest.xml](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/android/app/src/main/AndroidManifest.xml)
- Add `<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />`.
- Add `<uses-permission android:name="android.permission.WAKE_LOCK" />` (ensure it's present).
- Add `android:showWhenLocked="true"` and `android:turnScreenOn="true"` to the `.MainActivity`.
- Ensure `ScheduledNotificationReceiver` and `ScheduledNotificationBootReceiver` are correctly configured within the `<application>` tag.

### Core Layer (Services)

#### [MODIFY] [pre_alarm_service.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/core/services/pre_alarm_service.dart)
- Update `AndroidNotificationDetails`:
    - Set `fullScreenIntent: true`.
    - Set `category: AndroidNotificationCategory.alarm`.
    - Ensure `priority: Priority.max` and `importance: Importance.max`.
- Ensure the `init()` method is robust for background start.

## Verification Plan

### Manual Verification
1. Run `flutter clean` and reinstall the app.
2. Set a bedtime 5 minutes from now.
3. **Kill the app** (swipe away from recent apps).
4. Lock the screen and wait.
5. Verify the notification triggers on time and wakes the screen/shows a banner.
