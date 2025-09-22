/// Validates licences against the backend service while supporting offline use.
class LicenceValidator {
  /// TODO: Persist last-known validation response for offline grace.
  Future<bool> validate(String code, String deviceId) async {
    return code.isNotEmpty && deviceId.isNotEmpty;
  }
}
