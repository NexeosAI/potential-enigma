/// Represents a note captured inside the workspace.
class WorkspaceNote {
  WorkspaceNote({
    required this.id,
    required this.folderId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String folderId;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
}
