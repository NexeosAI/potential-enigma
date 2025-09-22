/// Represents a learner or guardian profile within the app.
class ProfileModel {
  ProfileModel({
    required this.id,
    required this.displayName,
    required this.isGuardian,
  });

  final String id;
  final String displayName;
  final bool isGuardian;
}
