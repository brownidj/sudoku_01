class InstalledTheme {
  final String id;
  final int version;
  final DateTime installedAt;
  final bool validated;
  final String rootPath;

  const InstalledTheme({
    required this.id,
    required this.version,
    required this.installedAt,
    required this.validated,
    required this.rootPath,
  });
}
