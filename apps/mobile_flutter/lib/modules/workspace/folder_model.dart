/// Represents a workspace folder grouping notes, files, and tags.
class WorkspaceFolder {
  WorkspaceFolder({
    required this.id,
    required this.name,
    this.parentId,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String? parentId;
  final List<String> tags;
}
