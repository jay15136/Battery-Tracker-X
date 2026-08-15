/// Resolves the host-specific root for application-managed persistent files.
///
/// Domain models store relative logical references and never store this URI.
abstract interface class AppDataDirectoryService {
  Future<Uri> getApplicationSupportRoot();
}
