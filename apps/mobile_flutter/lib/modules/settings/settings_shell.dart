import 'package:flutter/material.dart';

import '../../branding/branding_config.dart';

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
        children: const [
          _ModelsTab(),
          _AddOnsTab(),
          _SyncTab(),
          _AccountTab(),
        ],
      ),
    );
  }
}

class _ModelsTab extends StatelessWidget {
  const _ModelsTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ToggleButtons(
            isSelected: const [true, false],
            onPressed: (_) {},
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
          Expanded(
            child: ListView(
              children: const [
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
              ],
            ),
          ),
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
        ),
      ],
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.verified_user),
          title: Text('Licence tier'),
          subtitle: Text('Tier 1 · 2/3 devices activated'),
        ),
        ListTile(
          leading: Icon(Icons.devices_other),
          title: Text('Manage devices'),
          subtitle: Text('Deactivate a device to free up a seat.'),
        ),
      ],
    );
  }
}
