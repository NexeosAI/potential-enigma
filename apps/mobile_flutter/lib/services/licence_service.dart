/// Client for interacting with the licensing backend.
class LicenceService {
  /// TODO: Replace with Supabase RPC calls.
  Future<Map<String, dynamic>> getCurrentTier(String brandId) async {
    return {
      'brandId': brandId,
      'tier': 1,
      'price': 29,
      'cap': 10000,
      'sold': 2000,
    };
  }

  Future<String> createLicence(String brandId, String email) async {
    // TODO: Trigger backend checkout + insert flow.
    return 'LICENCE-${brandId.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<bool> activateLicence(String code, String deviceId) async {
    // TODO: Check device limits via backend service.
    return code.isNotEmpty && deviceId.isNotEmpty;
  }

  Future<bool> validateLicence(String code, String deviceId) async {
    // TODO: Call backend validation endpoint.
    return code.isNotEmpty && deviceId.isNotEmpty;
  }
}
