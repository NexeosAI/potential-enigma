codex/create-working-plan-from-agents.md-gyf1jn
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Client for interacting with the licensing backend via Supabase RPCs.
class LicenceService {
  LicenceService({SupabaseClient? client}) : _client = client ?? _resolveClient();

  final SupabaseClient _client;

  static SupabaseClient _resolveClient() {
    try {
      return Supabase.instance.client;
    } catch (error) {
      throw StateError(
        'Supabase has not been initialised. Call Supabase.initialize before using LicenceService or provide a client explicitly.',
      );
    }
  }

  Future<LicenceTier> getCurrentTier(String brandId) async {
    final response = await _client.rpc('get_current_tier', params: {
      'p_brand_id': brandId,
    });

    final tierMap = _mapFromResponse(response);
    if (tierMap == null) {
      throw StateError('No active tier returned for brand $brandId');
    }

    final currency = await _fetchCurrencyForBrand(brandId);

    return LicenceTier(
      brandId: brandId,
      sequence: tierMap['sequence'] as int,
      price: (tierMap['price'] as num).toDouble(),
      cap: tierMap['cap'] as int?,
      sold: (tierMap['sold'] as num).toInt(),
      currency: currency,
    );
  }

  Future<LicenceIssue> createLicence(String brandId, String email) async {
    final response = await _client.rpc('create_licence', params: {
      'p_brand_id': brandId,
      'p_email': email,
    });

    final data = _mapFromResponse(response);
    if (data == null) {
      throw StateError('Supabase returned an empty payload when creating a licence');
    }

    return LicenceIssue(
      licenceId: data['licence_id'] as String,
      code: data['code'] as String,
      tierSequence: data['tier_sequence'] as int,
      price: (data['price'] as num?)?.toDouble(),
    );
  }

  Future<LicenceActivationResult> activateLicence(String code, String deviceId) async {
    final response = await _client.rpc('activate_licence', params: {
      'p_licence_code': code,
      'p_device_id': deviceId,
    });

    final data = _mapFromResponse(response);
    if (data == null) {
      throw StateError('Activation RPC returned no payload');
    }

    return LicenceActivationResult(
      licenceId: data['licence_id'] as String,
      deviceId: data['device_id'] as String,
      status: data['status'] as String? ?? 'unknown',
      deviceCount: (data['device_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<LicenceValidationResult> validateLicence(String code, String deviceId) async {
    final response = await _client.rpc('validate_licence', params: {
      'p_licence_code': code,
      'p_device_id': deviceId,
    });

    final data = _mapFromResponse(response);
    if (data == null) {
      throw StateError('Validation RPC returned no payload');
    }

    final lastValidated = data['last_validated_at'] != null
        ? DateTime.tryParse(data['last_validated_at'] as String)
        : null;
    final graceExpiry = data['grace_expires_at'] != null
        ? DateTime.tryParse(data['grace_expires_at'] as String)
        : null;

    return LicenceValidationResult(
      licenceId: data['licence_id'] as String,
      deviceId: data['device_id'] as String? ?? deviceId,
      status: data['status'] as String? ?? 'unknown',
      lastValidatedAt: lastValidated,
      graceExpiresAt: graceExpiry,
    );
  }

  Map<String, dynamic>? _mapFromResponse(dynamic response) {
    if (response == null) {
      return null;
    }

    if (response is PostgrestResponse) {
      return _mapFromResponse(response.data);
    }

    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is List) {
      return response.whereType<Map<String, dynamic>>().firstWhereOrNull((_) => true);
    }

    return null;
  }

  Future<String> _fetchCurrencyForBrand(String brandId) async {
    final query = await _client
        .from('brands')
        .select('default_currency')
        .eq('id', brandId)
        .maybeSingle();

    if (query.error != null) {
      throw query.error!;
    }

    final currency = query.data?['default_currency'] as String?;
    if (currency == null) {
      throw StateError('Currency missing for brand $brandId');
    }

    return currency;
  }
}

class LicenceTier {
  const LicenceTier({
    required this.brandId,
    required this.sequence,
    required this.price,
    required this.cap,
    required this.sold,
    required this.currency,
  });

  final String brandId;
  final int sequence;
  final double price;
  final int? cap;
  final int sold;
  final String currency;

  bool get hasRemainingSeats => cap == null || sold < cap!;
}

class LicenceIssue {
  const LicenceIssue({
    required this.licenceId,
    required this.code,
    required this.tierSequence,
    this.price,
  });

  final String licenceId;
  final String code;
  final int tierSequence;
  final double? price;
}

class LicenceActivationResult {
  const LicenceActivationResult({
    required this.licenceId,
    required this.deviceId,
    required this.status,
    required this.deviceCount,
  });

  final String licenceId;
  final String deviceId;
  final String status;
  final int deviceCount;

  bool get success => status == 'active';
}

class LicenceValidationResult {
  const LicenceValidationResult({
    required this.licenceId,
    required this.deviceId,
    required this.status,
    required this.lastValidatedAt,
    required this.graceExpiresAt,
  });

  final String licenceId;
  final String deviceId;
  final String status;
  final DateTime? lastValidatedAt;
  final DateTime? graceExpiresAt;

  bool get isActive => status == 'active';
  bool get isGracePeriod =>
      status == 'active' && graceExpiresAt != null && graceExpiresAt!.isAfter(DateTime.now());
  bool get isExpired => status == 'grace_expired';

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
main
}
