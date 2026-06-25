import 'package:aethel_product_shells/aethel_product_shells.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OmegaLibraryGraph', () {
    test('groups nodes by omega receipt stage', () {
      final nodes = [
        OmegaLibraryReceiptNode(
          title: 'Signal page',
          url: 'https://example.com/a',
          entityId: '11111111-1111-4111-8111-111111111111',
          epistemicStage: 'omega0_signal',
          lastSeen: DateTime.utc(2026, 6, 2),
        ),
        OmegaLibraryReceiptNode(
          title: 'Inquiry topic',
          url: 'https://example.com/b',
          entityId: '33333333-3333-4333-8333-333333333333',
          epistemicStage: 'inquiry',
          lastSeen: DateTime.utc(2026, 6, 3),
        ),
      ];

      final grouped = OmegaLibraryGraph.groupByStage(nodes);
      expect(grouped['inquiry'], hasLength(1));
      expect(grouped['omega0_signal'], hasLength(1));
    });

    test('merges local library matches before remote evidence', () {
      final local = [
        OmegaLibraryReceiptNode(
          title: 'Local match',
          url: 'https://example.com/local',
          entityId: '11111111-1111-4111-8111-111111111111',
          epistemicStage: 'omega0_signal',
          lastSeen: DateTime.utc(2026, 6, 2),
        ),
      ];
      const remote = [
        OmegaEvidenceRef(
          entityId: '55555555-5555-4555-8555-555555555555',
          label: 'Remote only',
          kind: 'resource',
          uri: 'https://example.com/remote',
        ),
      ];

      final merged = OmegaLibraryGraph.mergeEvidence(
        localMatches: local,
        remote: remote,
        limit: 4,
      );

      expect(merged.first.entityId, '11111111-1111-4111-8111-111111111111');
      expect(merged, hasLength(2));
    });
  });
}
