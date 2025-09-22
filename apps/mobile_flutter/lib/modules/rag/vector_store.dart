/// Provides a simple interface for persisting and querying embeddings.
class VectorStore {
  /// TODO: Backed by SQLite + FAISS/LanceDB hybrid implementation.
  Future<void> save(String documentId, List<double> vector) async {}

  /// TODO: Implement nearest-neighbour query logic.
  Future<List<String>> query(List<double> vector) async {
    return const [];
  }
}
