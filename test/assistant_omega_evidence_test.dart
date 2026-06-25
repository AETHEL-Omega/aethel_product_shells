import 'package:aethel_product_shells/aethel_product_shells.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssistantOmegaEvidence', () {
    test('builds bounded prompt block with local-first evidence', () async {
      final block = await AssistantOmegaEvidence.buildPromptBlock(
        port: _StubPort(),
        query: 'merge sort',
        libraryNodes: [
          OmegaLibraryReceiptNode(
            title: 'Merge sort notes',
            url: 'https://example.com/merge-sort',
            entityId: '11111111-1111-4111-8111-111111111111',
            epistemicStage: 'omega0_signal',
            lastSeen: DateTime.utc(2026, 6, 2),
          ),
        ],
      );

      expect(block, contains('Omega evidence set'));
      expect(block, contains('omega:11111111-1111-4111-8111-111111111111'));
      expect(block, contains('not canonical truth'));
    });
  });
}

class _StubPort implements OmegaReadPlanePort {
  @override
  Future<bool> isReachable() async => true;

  @override
  Future<OmegaWorkspaceMeta> fetchWorkspaceMeta({bool forceRefresh = false}) async =>
      throw UnimplementedError();

  @override
  Future<OmegaScienceStatus> fetchScienceStatus() async => throw UnimplementedError();

  @override
  Future<List<OmegaEvidenceRef>> searchEvidence(OmegaEvidenceQuery query) async {
    return const [
      OmegaEvidenceRef(
        entityId: '55555555-5555-4555-8555-555555555555',
        label: 'Remote merge sort',
        kind: 'resource',
        uri: 'https://example.com/remote-merge',
      ),
    ];
  }

  @override
  Future<OmegaTraceRef?> traceForEntity(String omegaEntityId) async => null;

  @override
  Future<OmegaPromotionProposal> proposePromotion(String omegaEntityId) async =>
      throw UnimplementedError();

  @override
  Future<OmegaFederationBundle> exportFederationBundle(
    String omegaEntityId, {
    String scope = 'public',
  }) async =>
      throw UnimplementedError();

  @override
  Future<OmegaInquiryChain?> inquiryChainForEntity(String omegaEntityId) async =>
      null;

  @override
  Future<OmegaFederationReceiveResult> receiveFederationBundle(
    Map<String, Object?> bundle,
  ) async =>
      throw UnimplementedError();

  @override
  Future<OmegaInquiryProposal> proposeInquiryAdvance(
    OmegaInquiryAdvanceRequest request,
  ) async =>
      throw UnimplementedError();

  @override
  Future<OmegaConflictProposal> proposeConflictResolution(
    OmegaConflictProposeRequest request,
  ) async =>
      throw UnimplementedError();
}
