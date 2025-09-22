# McCaigs Education AI Suite — Mobile Scaffold

This directory contains the Flutter scaffold for the StudentlyAI, StudentsAI UK,
and StudentsAI US mobile application. The project follows an MAID-style module
layout so features can iterate independently while sharing services and
branding.

## Structure

- `lib/main.dart` — entry point pulling `APP_BRAND` from build flags.
- `lib/app.dart` — wraps the MaterialApp shell and routes to the settings panel.
- `lib/branding/branding_config.dart` — declares brand theming and metadata.
- `lib/modules` — feature modules for chat, workspace, models, sync, tools, auth.
- `lib/services` — API-facing abstractions for licensing and marketplace data.

## Next Steps

1. Run `flutter pub get` after installing Flutter 3.22+.
2. Flesh out module implementations and connect to real backend services.
3. Replace placeholder data within services and UI widgets.
