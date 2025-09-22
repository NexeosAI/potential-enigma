codex/create-working-plan-from-agents.md-gyf1jn
import 'package:supabase_flutter/supabase_flutter.dart';

/// Client abstraction for marketplace inventory and purchases.
class MarketplaceService {
  MarketplaceService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<AddonListing>> getAvailableAddOns(String brandId) async {
    final response = await _client.rpc('get_available_addons', params: {
      'p_brand_id': brandId,
    });

    final rows = _coerceList(response);
    if (rows.isEmpty) {
      return const [];
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(
          (row) => AddonListing(
            id: row['id'] as String,
            name: row['display_name'] as String,
            description: row['description'] as String,
            priceCents: (row['price_cents'] as num?)?.toInt() ?? 0,
            currency: (row['currency'] as String?) ?? 'GBP',
          ),
        )
        .toList();
  }

  Future<List<PurchasedAddon>> getPurchasedAddOns({
    required String brandId,
    required String email,
  }) async {
    final response = await _client.rpc('get_purchased_addons', params: {
      'p_brand_id': brandId,
      'p_email': email,
    });

    final rows = _coerceList(response);
    if (rows.isEmpty) {
      return const [];
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(
          (row) => PurchasedAddon(
            addonId: row['addon_id'] as String,
            version: row['version'] as String?,
            downloadUrl: row['download_url'] as String?,
            purchasedAt: row['purchased_at'] != null
                ? DateTime.tryParse(row['purchased_at'] as String)
                : null,
          ),
        )
        .toList();
  }

  Future<AddonPurchaseReceipt> recordPurchase({
    required String addonId,
    required String brandId,
    required String email,
    int? priceCents,
  }) async {
    final response = await _client.rpc('record_addon_purchase', params: {
      'p_addon_id': addonId,
      'p_brand_id': brandId,
      'p_email': email,
      'p_price_cents': priceCents,
    });

    final rows = _coerceList(response).whereType<Map<String, dynamic>>().toList();
    if (rows.isEmpty) {
      throw StateError('Supabase did not return a purchase receipt');
    }

    final row = rows.first;
    return AddonPurchaseReceipt(
      purchaseId: row['purchase_id'] as String,
      addonId: row['addon_id'] as String,
      pricePaidCents: (row['price_paid'] as num?)?.toInt() ?? priceCents ?? 0,
      purchasedAt: row['purchased_at'] != null
          ? DateTime.tryParse(row['purchased_at'] as String)
          : null,
    );
  }
}

class AddonListing {
  const AddonListing({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.currency,
  });

  final String id;
  final String name;
  final String description;
  final int priceCents;
  final String currency;

  String get formattedPrice =>
      priceCents == 0 ? 'Included' : '${currencySymbol(currency)}${(priceCents / 100).toStringAsFixed(2)}';

  static String currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return '$';
      case 'EUR':
        return '€';
      case 'GBP':
      default:
        return '£';
    }
  }
}

class PurchasedAddon {
  const PurchasedAddon({
    required this.addonId,
    this.version,
    this.downloadUrl,
    this.purchasedAt,
  });

  final String addonId;
  final String? version;
  final String? downloadUrl;
  final DateTime? purchasedAt;
}

class AddonPurchaseReceipt {
  const AddonPurchaseReceipt({
    required this.purchaseId,
    required this.addonId,
    required this.pricePaidCents,
    this.purchasedAt,
  });

  final String purchaseId;
  final String addonId;
  final int pricePaidCents;
  final DateTime? purchasedAt;
}

List<dynamic> _coerceList(dynamic response) {
  if (response == null) {
    return const [];
  }
  if (response is PostgrestResponse) {
    return _coerceList(response.data);
  }
  if (response is List) {
    return response;
  }
  return [response];

/// Client abstraction for marketplace inventory and purchases.
class MarketplaceService {
  /// TODO: Load from Supabase/REST endpoint.
  Future<List<Map<String, dynamic>>> getAvailableAddOns(String brandId) async {
    return [
      {
        'id': 'research_pack',
        'name': 'Research Pack',
        'price': 19,
        'brandId': brandId,
      },
      {
        'id': 'career_pack',
        'name': 'Career Pack',
        'price': 15,
        'brandId': brandId,
      },
    ];
  }

  /// TODO: Implement purchase flow integration.
  Future<void> purchase(String addonId) async {}
main
}
