import 'package:meta/meta.dart';

@immutable
class OmegaOmnibarEvidenceSuggestion {
  const OmegaOmnibarEvidenceSuggestion({
    required this.url,
    required this.title,
    required this.subtitle,
    required this.entityId,
    this.score = 12,
  });

  final String url;
  final String title;
  final String subtitle;
  final String entityId;
  final double score;
}
