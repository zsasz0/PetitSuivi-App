/// Centralized API configuration for the SmartKids application.
///
/// This class holds the base URL used by all services.
class ApiConstants {
  /// The root URL of the backend server.
  /// Docker builds can override this at compile time for local stacks.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.petitsuivi.me',
  );
}
