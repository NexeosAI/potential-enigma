/// Placeholder adapter for institutional integrations (schools, universities).
class InstitutionAdapter {
  Future<InstitutionConfiguration> configureInstitution(String institutionId) async {
    return InstitutionConfiguration(
      institutionId: institutionId,
      licencesProvisioned: 0,
      notes: 'Integration pending',
    );
  }
}

class InstitutionConfiguration {
  const InstitutionConfiguration({
    required this.institutionId,
    required this.licencesProvisioned,
    required this.notes,
  });

  final String institutionId;
  final int licencesProvisioned;
  final String notes;
}
