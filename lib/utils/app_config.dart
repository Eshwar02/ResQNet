/// API Configuration
class ApiConfig {
  // Base URL for backend API
  // Update this with your backend server URL
  static const String baseUrl = 'http://localhost:3000';
  
  // API Endpoints
  static const String hospitalsEndpoint = '/hospitals';
  static const String emergencyEndpoint = '/emergency';
  static const String nearestHospitalsEndpoint = '/nearest-hospitals';
  
  // Timeout durations
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
}

/// App Configuration
class AppConfig {
  // Emergency Services
  static const String emergencyNumber = '108';
  
  // Map Configuration
  static const double defaultLatitude = 13.0827;
  static const double defaultLongitude = 80.2707;
  static const double defaultZoom = 13.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 5.0;
  
  // Ambulance Simulation
  static const int ambulanceUpdateInterval = 2; // seconds
  static const double ambulanceSpeed = 0.0005; // degrees per update
  
  // Location Settings
  static const double locationAccuracy = 100.0; // meters
  static const int locationTimeoutSeconds = 30;
}

/// App Strings
class AppStrings {
  // App Name
  static const String appName = 'ResQNet';
  
  // Home Screen
  static const String homeTitle = 'Emergency Ambulance';
  static const String emergencyButton = 'EMERGENCY';
  static const String callEmergency = 'Call 108';
  static const String myContacts = 'My Contacts';
  
  // Status Messages
  static const String findingHelp = 'Finding help...';
  static const String controlRoomNotified = 'Control room notified';
  static const String ambulanceAssigned = 'Ambulance assigned';
  static const String ambulanceArriving = 'Ambulance arriving...';
  static const String locationFetching = 'Fetching your location...';
  
  // Error Messages
  static const String noInternet = 'No internet connection';
  static const String locationError = 'Unable to get location';
  static const String permissionDenied = 'Permission denied';
  static const String apiError = 'Something went wrong';
  
  // Screen Titles
  static const String hospitalsTitle = 'Nearby Hospitals';
  static const String contactsTitle = 'Emergency Contacts';
  static const String mapTitle = 'Live Map';
}
