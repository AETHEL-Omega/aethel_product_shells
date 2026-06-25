/// Minimal navigable URL check for Ω evidence omnibar suggestions.
abstract final class OmegaNavigableUrl {
  OmegaNavigableUrl._();

  static bool isNavigable(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty || trimmed == 'about:blank') return false;
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('javascript:')) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    if (uri.host.isEmpty) return false;
    if (uri.host.contains('duckduckgo.com') &&
        uri.queryParameters.containsKey('q')) {
      return false;
    }
    return true;
  }

  static String dedupeKey(String url) => url.trim().toLowerCase();
}
