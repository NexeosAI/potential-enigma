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
}
