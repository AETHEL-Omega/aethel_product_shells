import '../models/omega_library_receipt_node.dart';
import '../models/omega_read_models.dart';
import '../port/omega_read_plane_port.dart';
import 'omega_library_graph.dart';

/// Bounded Ω evidence block for assistant / LLM workspace (slice 6).
abstract final class AssistantOmegaEvidence {
  AssistantOmegaEvidence._();

  static Future<String> buildPromptBlock({
    required OmegaReadPlanePort port,
    required String query,
    Iterable<OmegaLibraryReceiptNode> libraryNodes = const [],
    int limit = 5,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return '';

    final local = OmegaLibraryGraph.localMatches(
      nodes: libraryNodes,
      query: trimmed,
      limit: limit,
    );
    List<OmegaEvidenceRef> remote = const [];
    try {
      remote = await port.searchEvidence(
        OmegaEvidenceQuery(q: trimmed, limit: limit),
      );
    } catch (_) {
      remote = const [];
    }

    final merged = OmegaLibraryGraph.mergeEvidence(
      localMatches: local,
      remote: remote,
      limit: limit,
    );
    if (merged.isEmpty) return '';

    final lines = <String>[
      'Omega evidence set (bounded read-plane; not canonical truth):',
      'Rules: cite as omega:<entityId>; personal ratings/attention are not verification.',
    ];
    for (final ref in merged) {
      final uri = ref.uri?.trim();
      lines.add(
        '- omega:${ref.entityId} kind=${ref.kind} stage=${ref.stageLabel} '
        'label=${ref.label}${uri != null && uri.isNotEmpty ? ' uri=$uri' : ''}',
      );
    }
    return lines.join('\n');
  }
}
