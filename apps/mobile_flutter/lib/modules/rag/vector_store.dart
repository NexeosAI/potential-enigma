import 'dart:math';

/// Represents a stored embedding chunk.
class VectorRecord {
  const VectorRecord({
    required this.documentId,
    required this.chunkId,
    required this.vector,
    required this.content,
    this.metadata = const {},
  });

  final String documentId;
  final String chunkId;
  final List<double> vector;
  final String content;
  final Map<String, dynamic> metadata;
}

/// Match returned from a vector search query.
class VectorMatch {
  const VectorMatch({
    required this.documentId,
    required this.chunkId,
    required this.score,
    required this.content,
    required this.metadata,
  });

  final String documentId;
  final String chunkId;
  final double score;
  final String content;
  final Map<String, dynamic> metadata;
}

/// Provides a simple interface for persisting and querying embeddings in-memory.
class VectorStore {
  final List<VectorRecord> _records = [];

  Future<void> save(VectorRecord record) async {
    _records.removeWhere((existing) => existing.chunkId == record.chunkId);
    _records.add(record);
  }

  Future<void> removeWhere(bool Function(VectorRecord record) predicate) async {
    _records.removeWhere(predicate);
  }

  Future<List<VectorMatch>> query(
    List<double> vector, {
    int limit = 5,
    double threshold = 0.2,
  }) async {
    if (vector.isEmpty) {
      return const [];
    }

    final matches = <VectorMatch>[];

    for (final record in _records) {
      final similarity = _cosineSimilarity(vector, record.vector);
      if (similarity < threshold) {
        continue;
      }

      matches.add(
        VectorMatch(
          documentId: record.documentId,
          chunkId: record.chunkId,
          score: similarity,
          content: record.content,
          metadata: record.metadata,
        ),
      );
    }

    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches.take(limit).toList();
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      return 0;
    }

    var dot = 0.0;
    var magnitudeA = 0.0;
    var magnitudeB = 0.0;

    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      magnitudeA += pow(a[i], 2).toDouble();
      magnitudeB += pow(b[i], 2).toDouble();
    }

    if (magnitudeA == 0 || magnitudeB == 0) {
      return 0;
    }

    return dot / (sqrt(magnitudeA) * sqrt(magnitudeB));
  }
}
