import '../models/omega_library_receipt_node.dart';
import '../models/omega_read_models.dart';

/// Groups library nodes by Ω epistemic stage for graph-style display (slice 6).
abstract final class OmegaLibraryGraph {
  OmegaLibraryGraph._();

  static const stageOrder = <String>[
    'inquiry',
    'omega0_signal',
    'omega1_observation',
    'other',
  ];

  static Map<String, List<OmegaLibraryReceiptNode>> groupByStage(
    Iterable<OmegaLibraryReceiptNode> nodes,
  ) {
    final grouped = <String, List<OmegaLibraryReceiptNode>>{
      for (final stage in stageOrder) stage: <OmegaLibraryReceiptNode>[],
    };
    for (final node in nodes) {
      final bucket = _bucketFor(node.epistemicStage);
      grouped[bucket]!.add(node);
    }
    for (final entry in grouped.entries) {
      entry.value.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    }
    return grouped;
  }

  static String stageTitle(String bucket) {
    switch (bucket) {
      case 'inquiry':
        return 'Inquiry';
      case 'omega0_signal':
        return 'Signal';
      case 'omega1_observation':
        return 'Observation';
      default:
        return 'Other';
    }
  }

  static List<OmegaLibraryReceiptNode> localMatches({
    required Iterable<OmegaLibraryReceiptNode> nodes,
    required String query,
    int limit = 8,
  }) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    final out = <OmegaLibraryReceiptNode>[];
    for (final node in nodes) {
      final haystack = '${node.title}\n${node.url}'.toLowerCase();
      if (!haystack.contains(needle)) continue;
      out.add(node);
      if (out.length >= limit) break;
    }
    return out;
  }

  static List<OmegaEvidenceRef> mergeEvidence({
    required List<OmegaLibraryReceiptNode> localMatches,
    required List<OmegaEvidenceRef> remote,
    int limit = 8,
  }) {
    final merged = <OmegaEvidenceRef>[];
    final seen = <String>{};

    for (final node in localMatches) {
      if (!seen.add(node.entityId)) continue;
      merged.add(
        OmegaEvidenceRef(
          entityId: node.entityId,
          label: node.displayLabel,
          kind: 'resource',
          epistemicStage: node.epistemicStage,
          uri: node.url,
        ),
      );
    }

    for (final ref in remote) {
      if (!seen.add(ref.entityId)) continue;
      merged.add(ref);
      if (merged.length >= limit) break;
    }

    return merged.take(limit).toList(growable: false);
  }

  static String _bucketFor(String stage) {
    if (stageOrder.contains(stage)) return stage;
    return 'other';
  }
}
