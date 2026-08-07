# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Fix for Missing classes detected while running R8
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.sidecar.**
-dontwarn com.google.android.gms.internal.**
-dontwarn com.facebook.**

# Play Core Fixes
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.common.internal.**
