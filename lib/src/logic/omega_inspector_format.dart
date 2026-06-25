import '../models/omega_read_models.dart';

List<String> formatOmegaInspectorLines({
  required String headerLine,
  OmegaTraceRef? trace,
  OmegaPromotionProposal? proposal,
  OmegaFederationBundle? federation,
  OmegaInquiryChain? inquiryChain,
  Object? error,
}) {
  return [
    headerLine,
    if (trace != null)
      'Trace ${trace.shortTraceId} · ${trace.mutation} · ${trace.outcome}',
    if (trace == null) 'Trace: none recorded',
    if (proposal != null)
      'Proposal ${proposal.fromLayer}→${proposal.toLayer}: '
          '${proposal.wouldAccept ? "would pass" : "blocked"}',
    if (proposal != null) proposal.message,
    if (federation != null)
      'Federation ${federation.federationScope}: '
          '${federation.allowed ? "${federation.evidence.length} evidence ref(s)" : "blocked"}',
    if (federation?.message != null) federation!.message!,
    if (inquiryChain != null) ...[
      'Inquiry ${inquiryChain.status}: ${inquiryChain.question}',
      if (inquiryChain.hypotheses.isNotEmpty)
        'Hypotheses: ${inquiryChain.hypotheses.length}',
      if (inquiryChain.experiments.isNotEmpty)
        'Experiments: ${inquiryChain.experiments.length}',
      if (inquiryChain.results.isNotEmpty) 'Results: ${inquiryChain.results.length}',
    ],
    if (error != null) 'Ω read-plane unavailable',
  ];
}
