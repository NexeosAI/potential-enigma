/// Coordinates on-device and cloud model availability.
class ModelManager {
  /// TODO: Surface installation state for GGUF packages.
  List<String> listInstalledModels() {
    return const ['Qwen3 0.6B'];
  }

  /// TODO: Integrate with Ollama/MLC for lifecycle management.
  Future<void> installModel(String model) async {}
}
