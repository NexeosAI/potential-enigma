/// Handles ingestion of supported document formats into the workspace layer.
class FileIngestionService {
  /// Supported file extensions for phase one.
  static const supportedExtensions = ['pdf', 'epub', 'docx', 'txt'];

  /// TODO: Implement splitting, metadata extraction, and storage on device.
  Future<void> ingest(String path) async {
    // Placeholder for ingestion pipeline.
  }
}
