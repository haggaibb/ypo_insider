import 'dart:js' as js;



void updateSplashScreenText(String message) {
  js.context.callMethod('updateStatusText', [message]);
}
void updateSplashScreenVersionText(String version) {
  js.context.callMethod('updateVersionText', [version]);
}


