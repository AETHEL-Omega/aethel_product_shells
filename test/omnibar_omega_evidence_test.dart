import 'package:aethel_product_shells/aethel_product_shells.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OmnibarOmegaEvidence', () {
    test('appends navigable evidence suggestions', () {
      final seen = {'https://example.com/local'};
      final evidence = [
        const OmegaEvidenceRef(
          entityId: '66666666-6666-4666-8666-666666666666',
          label: 'Merge Sort Notes',
          kind: 'resource',
          epistemicStage: 'omega0_signal',
          uri: 'https://example.com/merge-sort',
        ),
      ];

      final suggestions = OmnibarOmegaEvidence.suggestionsFromEvidence(
        seenUrlKeysLower: seen,
        evidence: evidence,
      );

      expect(suggestions, hasLength(1));
      expect(suggestions.single.entityId, evidence.first.entityId);
      expect(suggestions.single.subtitle, contains('Ω Evidence'));
    });

    test('skips evidence without navigable uri and dedupes urls', () {
      final seen = {'https://example.com/paper'};
      final evidence = [
        const OmegaEvidenceRef(
          entityId: '11111111-1111-4111-8111-111111111111',
          label: 'Duplicate',
          kind: 'resource',
          uri: 'https://example.com/paper',
        ),
        const OmegaEvidenceRef(
          entityId: '22222222-2222-4222-8222-222222222222',
          label: 'No link',
          kind: 'knowledge',
        ),
      ];

      final suggestions = OmnibarOmegaEvidence.suggestionsFromEvidence(
        seenUrlKeysLower: seen,
        evidence: evidence,
      );

      expect(suggestions, isEmpty);
    });
  });

  group('OmegaNavigableUrl', () {
    test('rejects non-http schemes', () {
      expect(OmegaNavigableUrl.isNavigable('javascript:alert(1)'), isFalse);
      expect(OmegaNavigableUrl.isNavigable('https://example.com'), isTrue);
    });
  });
}
