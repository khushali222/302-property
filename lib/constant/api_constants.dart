class ApiConstants {
  static const String baseUrl = 'https://staging.cloudrentalmanager.com';

  static Future<Map<String, String>> getHeaders() async {
    // TODO: Implement proper authentication headers
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
