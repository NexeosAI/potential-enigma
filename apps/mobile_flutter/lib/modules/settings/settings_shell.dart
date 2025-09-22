codex/create-working-plan-from-agents.md-0qnebh

codex/create-working-plan-from-agents.md-gyf1jn
main
import 'dart:async';

import 'package:flutter/material.dart';

import '../../branding/branding_config.dart';
import '../marketplace/marketplace_tab.dart';
import '../sync/drive_adapter.dart';
import '../sync/institution_adapter.dart';
import '../sync/p2p_sync.dart';

 codex/create-working-plan-from-agents.md-0qnebh

import 'package:flutter/material.dart';

import '../../branding/branding_config.dart';
main

main
class SettingsShell extends StatefulWidget {
  const SettingsShell({super.key, required this.brand});

  final AppBrand brand;

  @override
  State<SettingsShell> createState() => _SettingsShellState();
}

class _SettingsShellState extends State<SettingsShell>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    Tab(text: 'Models'),
    Tab(text: 'Add-ons'),
    Tab(text: 'Sync'),
    Tab(text: 'Account'),
  ];

  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.brand.config;
    return Scaffold(
      appBar: AppBar(
        title: Text(config.displayName),
        bottom: TabBar(
          controller: _controller,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          const _ModelsTab(),
codex/create-working-plan-from-agents.md-0qnebh
          MarketplaceTab(brand: widget.brand),

 codex/create-working-plan-from-agents.md-gyf1jn
          MarketplaceTab(brand: widget.brand),

          const _AddOnsTab(),
 main
main
          const _SyncTab(),
          _AccountTab(config: config),
        ],
      ),
    );
  }
}

class _ModelsTab extends StatefulWidget {
  const _ModelsTab();

  @override
  State<_ModelsTab> createState() => _ModelsTabState();
}

class _ModelsTabState extends State<_ModelsTab> {
  int _selectedToggle = 0;

  @override
  Widget build(BuildContext context) {
    final tiles = _selectedToggle == 0
        ? const [
            ListTile(
              title: Text('Qwen3 0.6B'),
              subtitle: Text('Installed'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
            ListTile(
              title: Text('Gemma3 1B'),
              subtitle: Text('Not installed'),
              trailing: Icon(Icons.download),
            ),
          ]
        : const [
            ListTile(
              title: Text('OpenRouter'),
              subtitle: Text('Connect your API key to access hosted models.'),
              trailing: Icon(Icons.lock_open),
            ),
          ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ToggleButtons(
            isSelected: List.generate(2, (index) => index == _selectedToggle),
            onPressed: (index) {
              setState(() {
                _selectedToggle = index;
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Local AI'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Cloud AI'),
              ),
            ],
          ),
          const SizedBox(height: 24),
codex/create-working-plan-from-agents.md-0qnebh

codex/create-working-plan-from-agents.md-gyf1jn
 main
          Expanded(
            child: ListView(children: tiles),
          ),
        ],
      ),
    );
  }
}

class _SyncTab extends StatefulWidget {
  const _SyncTab();

  @override
  State<_SyncTab> createState() => _SyncTabState();
}

class _SyncTabState extends State<_SyncTab> {
  final P2PSync _p2pSync = P2PSync();
  final DriveAdapter _driveAdapter = DriveAdapter();
  final InstitutionAdapter _institutionAdapter = InstitutionAdapter();
  final TextEditingController _institutionController = TextEditingController();

  StreamSubscription<P2PSyncState>? _subscription;
  String? _pairingCode;
  String _syncStatus = 'Ready to pair devices';
  final Set<String> _connectedDrives = <String>{};

  @override
  void initState() {
    super.initState();
    _subscription = _p2pSync.statusStream.listen((state) {
      setState(() {
        _syncStatus = state.message;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _p2pSync.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    final code = await _p2pSync.generatePairingCode();
    setState(() {
      _pairingCode = code;
    });
  }

  Future<void> _startPairing() async {
    if (_pairingCode == null) {
      await _generateCode();
    }
    if (_pairingCode != null) {
      await _p2pSync.startSession(_pairingCode!);
    }
  }

  Future<void> _toggleDrive(String provider, bool connect) async {
    if (connect) {
      await _driveAdapter.connect(provider);
      setState(() => _connectedDrives.add(provider));
    } else {
      await _driveAdapter.disconnect(provider);
      setState(() => _connectedDrives.remove(provider));
    }
  }

  Future<void> _provisionInstitution() async {
    if (_institutionController.text.isEmpty) {
      return;
    }
    final result = await _institutionAdapter.configureInstitution(_institutionController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Provisioned ${result.institutionId} (${result.notes}).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const driveOptions = <String, String>{
      'google_drive': 'Google Drive',
      'icloud': 'Apple iCloud',
      'dropbox': 'Dropbox',
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Peer-to-peer sync', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(_syncStatus),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: _generateCode,
              icon: const Icon(Icons.qr_code_2),
              label: Text(_pairingCode == null ? 'Generate QR code' : 'Code: $_pairingCode'),
            ),
            OutlinedButton.icon(
              onPressed: _startPairing,
              icon: const Icon(Icons.link),
              label: const Text('Start pairing'),
            ),
          ],
        ),
        const Divider(height: 32),
        Text('Cloud drives', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            for (final entry in driveOptions.entries)
              FilterChip(
                label: Text(entry.value),
                selected: _connectedDrives.contains(entry.key),
                onSelected: (selected) => _toggleDrive(entry.key, selected),
              ),
          ],
        ),
        const Divider(height: 32),
        Text('Institutional sync', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _institutionController,
          decoration: const InputDecoration(
            labelText: 'Institution ID',
            hintText: 'mccaigs-university',
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _provisionInstitution,
          icon: const Icon(Icons.school),
          label: const Text('Request provisioning'),
codex/create-working-plan-from-agents.md-0qnebh


          Expanded(child: ListView(children: tiles)),
        ],
      ),
    );
  }
}

class _AddOnsTab extends StatelessWidget {
  const _AddOnsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Research Pack'),
            subtitle: Text('Deep search, references, and academic tone.'),
            trailing: TextButton(onPressed: null, child: Text('Coming Soon')),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Career Pack'),
            subtitle: Text('CV builder, interview prep, and job tracking.'),
            trailing: TextButton(onPressed: null, child: Text('Coming Soon')),
          ),
        ),
      ],
    );
  }
}

class _SyncTab extends StatelessWidget {
  const _SyncTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.qr_code_2),
          title: Text('Peer-to-peer sync'),
          subtitle: Text('Generate a QR code to sync devices securely.'),
        ),
        ListTile(
          leading: Icon(Icons.cloud_outlined),
          title: Text('Cloud drives'),
          subtitle: Text('Connect Google Drive, iCloud, or Dropbox.'),
main
main
        ),
      ],
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab({required this.config});

  final BrandConfig config;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.verified_user),
          title: Text(config.adaptSpelling('Licence tier')),
          subtitle: Text('${config.currency}29 · 2/3 devices active'),
        ),
        ListTile(
          leading: const Icon(Icons.devices_other),
          title: Text(config.adaptSpelling('Manage licences')),
          subtitle: Text(config
              .adaptSpelling('Deactivate a device to free up a licence seat.')),
        ),
      ],
    );
  }
}
