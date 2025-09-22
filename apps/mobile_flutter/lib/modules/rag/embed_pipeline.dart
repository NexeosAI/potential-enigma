codex/create-working-plan-from-agents.md-gyf1jn
import 'dart:math';

import 'package:collection/collection.dart';

import 'vector_store.dart';

/// Coordinates text chunking and embedding so content can be stored for retrieval.
class EmbedPipeline {
  EmbedPipeline({VectorStore? store}) : _store = store ?? VectorStore();

  static const int _dimensions = 128;
  static const int _chunkSize = 400;

  final VectorStore _store;

  VectorStore get store => _store;

  /// Splits a document into small chunks, embeds, and saves them to the vector store.
  Future<List<EmbeddedChunk>> indexDocument({
    required String documentId,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final chunks = _chunk(content, _chunkSize);
    final results = <EmbeddedChunk>[];

    for (var index = 0; index < chunks.length; index++) {
      final chunkContent = chunks[index];
      final vector = await embedText(chunkContent);
      final chunkId = '$documentId#$index';

      final record = VectorRecord(
        documentId: documentId,
        chunkId: chunkId,
        vector: vector,
        content: chunkContent,
        metadata: {
          'order': index,
          if (metadata != null) ...metadata,
        },
      );

      await _store.save(record);
      results.add(EmbeddedChunk(record: record));
    }

    return results;
  }

  /// Generates a dense vector representation for an arbitrary query.
  Future<List<double>> embedQuery(String query) => embedText(query);

  /// Generates a deterministic embedding vector using a hashing trick.
  Future<List<double>> embedText(String text) async {
    final tokens = _tokenise(text);
    if (tokens.isEmpty) {
      return List<double>.filled(_dimensions, 0);
    }

    final vector = List<double>.filled(_dimensions, 0);
    for (final token in tokens) {
      final hash = token.hashCode;
      final index = hash.abs() % _dimensions;
      final sign = hash.isEven ? 1.0 : -1.0;
      vector[index] += sign;
    }

    _normalise(vector);
    return vector;
  }

  /// Removes all indexed chunks for the provided document identifier.
  Future<void> removeDocument(String documentId) async {
    await _store.removeWhere((record) => record.documentId == documentId);
  }

  List<String> _chunk(String text, int size) {
    final words = _tokenise(text, keepStopWords: true);
    if (words.isEmpty) {
      return const [];
    }

    final List<String> chunks = [];
    final buffer = <String>[];

    for (final word in words) {
      buffer.add(word);
      if (buffer.join(' ').length >= size) {
        chunks.add(buffer.join(' '));
        buffer.clear();
      }
    }

    if (buffer.isNotEmpty) {
      chunks.add(buffer.join(' '));
    }

    return chunks;
  }

  List<String> _tokenise(String text, {bool keepStopWords = false}) {
    final normalised = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();

    if (keepStopWords) {
      return normalised;
    }

    const stopWords = {
      'the',
      'and',
      'or',
      'to',
      'of',
      'for',
      'a',
      'is',
      'in',
      'on',
      'with',
    };

    return normalised.whereNot(stopWords.contains).toList();
  }

  void _normalise(List<double> vector) {
    final magnitude = sqrt(vector.fold<double>(0, (value, element) => value + element * element));
    if (magnitude == 0) {
      return;
    }

    for (var i = 0; i < vector.length; i++) {
      vector[i] = vector[i] / magnitude;
    }
  }
}

class EmbeddedChunk {
  const EmbeddedChunk({required this.record});

  final VectorRecord record;

/// Stub for the embedding pipeline that will convert notes and documents
/// into vector representations for retrieval.
class EmbedPipeline {
  /// TODO: Plug in BGE-small or e5-small GGUF embeddings via MLC.
  Future<void> indexDocument(String documentId) async {}
 main
}
