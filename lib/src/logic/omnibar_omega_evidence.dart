import '../models/omega_omnibar_evidence_suggestion.dart';
import '../models/omega_read_models.dart';
import 'omega_navigable_url.dart';

/// Filters and maps Ω evidence refs into omnibar-ready suggestions.
abstract final class OmnibarOmegaEvidence {
  OmnibarOmegaEvidence._();

  static const defaultEvidenceScore = 12.0;

  static List<OmegaOmnibarEvidenceSuggestion> suggestionsFromEvidence({
    required Set<String> seenUrlKeysLower,
    required List<OmegaEvidenceRef> evidence,
    double score = defaultEvidenceScore,
  }) {
    if (evidence.isEmpty) return const [];

    final out = <OmegaOmnibarEvidenceSuggestion>[];
    for (final ref in evidence) {
      final uri = ref.uri?.trim() ?? '';
      if (uri.isEmpty || !OmegaNavigableUrl.isNavigable(uri)) continue;
      final key = OmegaNavigableUrl.dedupeKey(uri);
      if (seenUrlKeysLower.contains(key)) continue;
      seenUrlKeysLower.add(key);
      out.add(
        OmegaOmnibarEvidenceSuggestion(
          url: uri,
          title: ref.label,
          subtitle: 'Ω Evidence · ${ref.stageLabel}',
          entityId: ref.entityId,
          score: score,
        ),
      );
    }
    return out;
  }
}
