import '../models/omega_read_models.dart';

abstract final class OmegaInquiryLogic {
  OmegaInquiryLogic._();

  static String? proposeStep(OmegaInquiryChain? chain) {
    if (chain == null || chain.status != 'open') return null;
    if (chain.hypotheses.isEmpty) return 'hypothesis';
    if (chain.experiments.isEmpty) return 'experiment';
    if (chain.results.isEmpty) return 'result';
    return null;
  }

  static String proposeTitle(String? step) {
    return switch (step) {
      'hypothesis' => 'Propose hypothesis (dry-run, no write)',
      'experiment' => 'Propose experiment (dry-run, no write)',
      'result' => 'Propose result (dry-run, no write)',
      _ => '',
    };
  }

  static String inputLabel(String? step) {
    return switch (step) {
      'hypothesis' => 'Hypothesis statement',
      'experiment' => 'Method (optional)',
      'result' => 'Finding',
      _ => '',
    };
  }

  static OmegaInquiryAdvanceRequest? buildAdvanceRequest({
    required OmegaInquiryChain chain,
    required String step,
    required String input,
  }) {
    return switch (step) {
      'hypothesis' => OmegaInquiryAdvanceRequest(
          step: step,
          questionId: chain.questionId,
          payload: {'statement': input},
        ),
      'experiment' => OmegaInquiryAdvanceRequest(
          step: step,
          questionId: chain.questionId,
          hypothesisId: chain.hypotheses.first.entityId,
          payload: {
            'hypothesis': chain.hypotheses.first.label,
            if (input.isNotEmpty) 'method': input,
          },
        ),
      'result' => OmegaInquiryAdvanceRequest(
          step: step,
          questionId: chain.questionId,
          experimentId: chain.experiments.first.entityId,
          payload: {'finding': input},
        ),
      _ => null,
    };
  }
}
