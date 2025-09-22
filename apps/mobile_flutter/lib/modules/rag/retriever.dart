import 'embed_pipeline.dart';
import 'vector_store.dart';
import 'citation_service.dart';

/// Orchestrates retrieval of relevant documents prior to generation.
class Retriever {
  Retriever({
    required EmbedPipeline embedPipeline,
    CitationService? citationService,
  })  : _embedPipeline = embedPipeline,
        _store = embedPipeline.store,
        _citationService = citationService ?? const CitationService();

  final EmbedPipeline _embedPipeline;
  final VectorStore _store;
  final CitationService _citationService;

  Future<List<RetrievedChunk>> fetchContext(
    String query, {
    int limit = 5,
  }) async {
    final queryVector = await _embedPipeline.embedQuery(query);
    final matches = await _store.query(queryVector, limit: limit);

    return matches
        .map(
          (match) => RetrievedChunk(
            documentId: match.documentId,
            chunkId: match.chunkId,
            content: match.content,
            score: match.score,
            citation: _citationService.format(
              match.documentId,
              metadata: match.metadata,
            ),
          ),
        )
        .toList();
  }
}

class RetrievedChunk {
  const RetrievedChunk({
    required this.documentId,
    required this.chunkId,
    required this.content,
    required this.score,
    required this.citation,
  });

  final String documentId;
  final String chunkId;
  final String content;
  final double score;
  final String citation;
}
