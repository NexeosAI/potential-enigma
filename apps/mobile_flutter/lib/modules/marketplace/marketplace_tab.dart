import 'package:flutter/material.dart';

import '../../branding/branding_config.dart';
import '../../services/marketplace_service.dart';

class MarketplaceTab extends StatefulWidget {
  const MarketplaceTab({super.key, required this.brand});

  final AppBrand brand;

  @override
  State<MarketplaceTab> createState() => _MarketplaceTabState();
}

class _MarketplaceTabState extends State<MarketplaceTab> {
  final MarketplaceService _service = MarketplaceService();
  final TextEditingController _emailController = TextEditingController();

  bool _loading = true;
  String? _error;
  List<AddonListing> _available = const [];
  List<PurchasedAddon> _purchased = const [];

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (_emailController.text.isEmpty) {
        setState(() {
          _purchased = const [];
        });
      }
    });
    _loadAddOns();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadAddOns({bool refreshPurchased = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final brandId = widget.brand.config.key;
      final available = await _service.getAvailableAddOns(brandId);
      List<PurchasedAddon> purchased = _purchased;

      if (refreshPurchased && _emailController.text.isNotEmpty) {
        purchased = await _service.getPurchasedAddOns(
          brandId: brandId,
          email: _emailController.text,
        );
      }

      setState(() {
        _available = available;
        _purchased = purchased;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to load add-ons: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _recordPurchase(AddonListing addon) async {
    if (_emailController.text.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter your licence email before recording purchases.')),
        );
      }
      return;
    }

    try {
      await _service.recordPurchase(
        addonId: addon.id,
        brandId: widget.brand.config.key,
        email: _emailController.text,
        priceCents: addon.priceCents,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Marked ${addon.name} as purchased for ${_emailController.text}.')),
        );
      }
      await _loadAddOns(refreshPurchased: true);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record purchase: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () => _loadAddOns(refreshPurchased: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Add-ons marketplace',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Licence email',
              hintText: 'student@example.com',
              suffixIcon: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _loadAddOns(refreshPurchased: true),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
            ),
          if (!_loading)
            ...[
              Text('Available add-ons', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              if (_available.isEmpty)
                const Text('Marketplace catalogue coming soon.'),
              ..._available.map(
                (addon) => Card(
                  child: ListTile(
                    title: Text(addon.name),
                    subtitle: Text(addon.description),
                    trailing: TextButton(
                      onPressed: () => _recordPurchase(addon),
                      child: Text('Buy • ${addon.formattedPrice}'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Your purchases', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              if (_purchased.isEmpty)
                const Text('Enter your licence email and tap refresh to load purchased add-ons.'),
              ..._purchased.map(
                (addon) => ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(addon.addonId),
                  subtitle: Text(
                    addon.version != null
                        ? 'Version ${addon.version} · ${addon.purchasedAt != null ? addon.purchasedAt!.toLocal().toString() : 'Recently added'}'
                        : 'Ready to install',
                  ),
                  trailing: addon.downloadUrl != null ? const Icon(Icons.download) : null,
                ),
              ),
            ],
        ],
      ),
    );
  }
}
