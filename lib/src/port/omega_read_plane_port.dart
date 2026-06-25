import '../models/omega_read_models.dart';

/// Read/propose HTTP surface shared by browser and terminal product shells (P54+).
abstract interface class OmegaReadPlanePort {
  Future<bool> isReachable();

  Future<OmegaWorkspaceMeta> fetchWorkspaceMeta({bool forceRefresh = false});

  Future<OmegaScienceStatus> fetchScienceStatus();

  Future<List<OmegaEvidenceRef>> searchEvidence(OmegaEvidenceQuery query);

  Future<OmegaTraceRef?> traceForEntity(String omegaEntityId);

  Future<OmegaPromotionProposal> proposePromotion(String omegaEntityId);

  Future<OmegaFederationBundle> exportFederationBundle(
    String omegaEntityId, {
    String scope = 'public',
  });

  Future<OmegaInquiryChain?> inquiryChainForEntity(String omegaEntityId);

  Future<OmegaFederationReceiveResult> receiveFederationBundle(
    Map<String, Object?> bundle,
  );

  Future<OmegaInquiryProposal> proposeInquiryAdvance(
    OmegaInquiryAdvanceRequest request,
  );

  Future<OmegaConflictProposal> proposeConflictResolution(
    OmegaConflictProposeRequest request,
  );
}
