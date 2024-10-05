import 'dart:js' as js;
import 'dart:html' as html;



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

Future<Map<String, dynamic>> getWebDeviceInfo() async {
  //print('here');
    //DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //print('here');

  //WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
  //print('here');
  Map<String, dynamic> deviceData = {
    'browserName': 'Unknown',  // Replace with actual detection logic if needed
    'userAgent': html.window.navigator.userAgent,
    'platform': html.window.navigator.platform,
    'appVersion': html.window.navigator.appVersion,
    'vendor': html.window.navigator.vendor,
    'hardwareConcurrency': html.window.navigator.hardwareConcurrency.toString(),
    'timestamp' : DateTime.now()
  };
  // Map<String, dynamic> deviceData = {
  //     'browserName': webBrowserInfo.browserName.name,   // Browser name as a string
  //     'userAgent': webBrowserInfo.userAgent ?? 'Unknown',  // User agent info
  //     'platform': webBrowserInfo.platform ?? 'Unknown',    // Platform info
  //     'appVersion': webBrowserInfo.appVersion ?? 'Unknown',  // App version
  //     'vendor': webBrowserInfo.vendor ?? 'Unknown',       // Vendor info
  //     'deviceMemory': webBrowserInfo.deviceMemory?.toString() ?? 'Unknown',  // Device memory
  //     'hardwareConcurrency': webBrowserInfo.hardwareConcurrency?.toString() ?? 'Unknown',  // CPU cores
  //     'timestamp': DateTime.now(),  // Add a timestamp for reference
  //   };
    ///
    // print('Browser Name: ${webBrowserInfo.browserName}');
    // print('User Agent: ${webBrowserInfo.userAgent}');
    // print('Platform: ${webBrowserInfo.platform}');
    // print('App Version: ${webBrowserInfo.appVersion}');
    // print('Vendor: ${webBrowserInfo.vendor}');
    // print('Device Memory: ${webBrowserInfo.deviceMemory}');
    // print('Hardware Concurrency (CPU cores): ${webBrowserInfo.hardwareConcurrency}');
    return deviceData;
}


Future<bool> isDeviceIOS(String userAgent) async {
  // Check if the userAgent contains 'iPhone'
  if (userAgent.contains('iPhone')) {
    return true;
  } else {
    return false;
  }
}