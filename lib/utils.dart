import 'dart:js' as js;
import 'dart:io' show Platform;
//import 'package:device_info_plus/device_info_plus.dart';
//import 'package:flutter/foundation.dart';



void updateSplashScreenText(String message) {
  js.context.callMethod('updateStatusText', [message]);
}
void updateSplashScreenVersionText(String version) {
  js.context.callMethod('updateVersionText', [version]);
}



String labelToKey(String label) {
  String key = label.toLowerCase();
  key = key.replaceAll(' ', '_');
  return key;
}

String getDeviceModel(String identifier) {
  Map<String, String> iosDeviceMap = {
    'iPhone11,8': 'iPhone XR',
    'iPhone12,1': 'iPhone 11',
    'iPhone12,3': 'iPhone 11 Pro',
    'iPhone13,1': 'iPhone 12 Mini',
    'iPhone13,2': 'iPhone 12',
    'iPhone13,3': 'iPhone 12 Pro',
    // Add more mappings as needed
  };

  return iosDeviceMap[identifier] ?? 'Unknown iPhone';
}

// Future<Map<String, dynamic>> getWebDeviceInfo() async {
//   if (kIsWeb) {
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
//     Map<String, dynamic> deviceData = {
//       'browserName': webBrowserInfo.browserName.name,   // Browser name as a string
//       'userAgent': webBrowserInfo.userAgent ?? 'Unknown',  // User agent info
//       'platform': webBrowserInfo.platform ?? 'Unknown',    // Platform info
//       'appVersion': webBrowserInfo.appVersion ?? 'Unknown',  // App version
//       'vendor': webBrowserInfo.vendor ?? 'Unknown',       // Vendor info
//       'deviceMemory': webBrowserInfo.deviceMemory?.toString() ?? 'Unknown',  // Device memory
//       'hardwareConcurrency': webBrowserInfo.hardwareConcurrency?.toString() ?? 'Unknown',  // CPU cores
//       'timestamp': DateTime.now(),  // Add a timestamp for reference
//     };
//     ///
//     // print('Browser Name: ${webBrowserInfo.browserName}');
//     // print('User Agent: ${webBrowserInfo.userAgent}');
//     // print('Platform: ${webBrowserInfo.platform}');
//     // print('App Version: ${webBrowserInfo.appVersion}');
//     // print('Vendor: ${webBrowserInfo.vendor}');
//     // print('Device Memory: ${webBrowserInfo.deviceMemory}');
//     // print('Hardware Concurrency (CPU cores): ${webBrowserInfo.hardwareConcurrency}');
//     return deviceData;
//   } else {
//     return {};
//   }
// }


// Future<bool> isDeviceIOS() async {
//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
//   // Check if the userAgent contains 'iPhone'
//   if (webBrowserInfo.userAgent != null && webBrowserInfo.userAgent!.contains('iPhone')) {
//     return true;
//   } else {
//     return false;
//   }
// }