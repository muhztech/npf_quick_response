class IncidentIdGenerator {
  static String generate() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'NPF-$timestamp';
  }
}
