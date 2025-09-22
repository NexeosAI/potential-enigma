/// Formats citations for generated answers.
class CitationService {
  /// TODO: Support APA and Harvard styles with localisation.
  String format(String sourceId, {String style = 'APA'}) {
    return '$style citation for $sourceId';
  }
}
