class AppConstants {
  static const String APP_NAME = 'Vibecheck';
  static const String DISPLAY_NAME = 'Vibecheck: Safe Crowd Guide';
  
  // NOTE: For physical Android devices via USB, use '127.0.0.1' and run `adb reverse tcp:5000 tcp:5000`
  // For Android Emulators, use '10.0.2.2'
  // For iOS simulators, use '127.0.0.1'
  static const String HOST_IP = '127.0.0.1'; 
  
  static const String API_BASE_URL = 'http://$HOST_IP:5000/api';
  static const String WS_BASE_URL = 'ws://$HOST_IP:5000/socket.io/?EIO=4&transport=websocket';
}
