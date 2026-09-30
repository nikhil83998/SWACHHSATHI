import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  /// Request Notification Permission (for Android 13+)
  static Future<void> requestNotificationPermission() async {
    if (kIsWeb) return;
    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } catch (e) {
      debugPrint("Notification permission request skipped: $e");
    }
  }

  /// Request Location Permission
  static Future<void> requestLocationPermission() async {
    if (kIsWeb) return;
    try {
      if (await Permission.location.isDenied) {
        await Permission.location.request();
      }
    } catch (e) {
      debugPrint("Location permission request skipped: $e");
    }
  }

  /// Request Camera Permission
  static Future<void> requestCameraPermission() async {
    if (kIsWeb) return;
    try {
      if (await Permission.camera.isDenied) {
        await Permission.camera.request();
      }
    } catch (e) {
      debugPrint("Camera permission request skipped: $e");
    }
  }

  /// Request Multiple Permissions at Once
  static Future<void> requestAllPermissions() async {
    if (kIsWeb) return;
    try {
      await [
        Permission.notification,
        Permission.location,
        Permission.camera,
      ].request();
    } catch (e) {
      debugPrint("Permissions request skipped: $e");
    }
  }
}
