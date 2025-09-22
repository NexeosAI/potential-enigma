/// Stub for the embedding pipeline that will convert notes and documents
/// into vector representations for retrieval.
class EmbedPipeline {
  /// TODO: Plug in BGE-small or e5-small GGUF embeddings via MLC.
  Future<void> indexDocument(String documentId) async {}
}
