/// Represents metadata for a downloadable or remote model option.
class ModelCard {
  const ModelCard({
    required this.id,
    required this.displayName,
    required this.sizeMb,
    required this.isInstalled,
  });

  final String id;
  final String displayName;
  final int sizeMb;
  final bool isInstalled;
}
