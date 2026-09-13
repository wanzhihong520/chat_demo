import 'package:flutter/services.dart';

class DeviceInfoPlugin {
  static const MethodChannel _channel = MethodChannel('device_info');

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final result = await _channel.invokeMethod<Object?>('getDeviceInfo');
    if (result is! Map) {
      throw StateError('Invalid device info response: expected a map');
    }
    return Map<String, dynamic>.from(result);
  }
}
