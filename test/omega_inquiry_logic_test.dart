import 'package:aethel_product_shells/aethel_product_shells.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OmegaInquiryLogic', () {
    test('proposeStep returns hypothesis when chain is open', () {
      const chain = OmegaInquiryChain(
        questionId: 'q1',
        question: 'Does it work?',
        status: 'open',
        hypotheses: [],
        experiments: [],
        results: [],
      );
      expect(OmegaInquiryLogic.proposeStep(chain), 'hypothesis');
    });

    test('buildAdvanceRequest creates hypothesis payload', () {
      const chain = OmegaInquiryChain(
        questionId: 'q1',
        question: 'Does it work?',
        status: 'open',
        hypotheses: [],
        experiments: [],
        results: [],
      );
      final req = OmegaInquiryLogic.buildAdvanceRequest(
        chain: chain,
        step: 'hypothesis',
        input: 'Yes it does',
      );
      expect(req?.step, 'hypothesis');
      expect(req?.payload['statement'], 'Yes it does');
    });
  });
}
