import 'dart:async';

/// Provides peer-to-peer sync placeholder for QR/WebRTC sharing.
class P2PSync {
  final _statusController = StreamController<P2PSyncState>.broadcast();

  Stream<P2PSyncState> get statusStream => _statusController.stream;

  Future<String> generatePairingCode() async {
    final code = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    _statusController.add(P2PSyncState(message: 'Generated pairing code $code'));
    return code;
  }

  Future<void> startSession(String code) async {
    _statusController.add(P2PSyncState(message: 'Attempting to pair with $code'));
    await Future<void>.delayed(const Duration(seconds: 1));
    _statusController.add(P2PSyncState(message: 'Connected to peer $code', isConnected: true));
  }

  Future<void> endSession() async {
    _statusController.add(const P2PSyncState(message: 'Session ended', isConnected: false));
  }

  void dispose() {
    _statusController.close();
  }
}

class P2PSyncState {
  const P2PSyncState({required this.message, this.isConnected = false});

  final String message;
  final bool isConnected;
}
