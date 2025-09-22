enum CitationStyle { apa, harvard }

/// Formats citations for generated answers.
class CitationService {
  const CitationService();

  String format(
    String sourceId, {
    CitationStyle style = CitationStyle.apa,
    Map<String, dynamic>? metadata,
  }) {
    final data = metadata ?? const {};
    switch (style) {
      case CitationStyle.harvard:
        return _harvard(sourceId, data);
      case CitationStyle.apa:
      default:
        return _apa(sourceId, data);
    }
  }

  String _apa(String sourceId, Map<String, dynamic> metadata) {
    final author = metadata['author'] ?? 'Unknown';
    final year = metadata['year']?.toString() ?? 'n.d.';
    final title = metadata['title'] ?? sourceId;
    final page = metadata['page'];
    final pageSuffix = page != null ? ', p. $page' : '';
    return '$author ($year). $title$pageSuffix.';
  }

  String _harvard(String sourceId, Map<String, dynamic> metadata) {
    final author = metadata['author'] ?? 'Unknown';
    final year = metadata['year']?.toString() ?? 'n.d.';
    final title = metadata['title'] ?? sourceId;
    final page = metadata['page'];
    final pageSuffix = page != null ? ', p. $page' : '';
    return '$author, $year. $title$pageSuffix';
  }
}
