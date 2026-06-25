import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';

import '../logic/omega_clipboard.dart';
import '../logic/omega_inquiry_logic.dart';
import '../logic/omega_inspector_format.dart';
import '../models/omega_read_models.dart';
import '../port/omega_read_plane_port.dart';

/// Shared Ω entity inspector content (Material).
class OmegaEntityInspectorBody extends StatefulWidget {
  const OmegaEntityInspectorBody({
    required this.port,
    required this.entity,
    required this.trace,
    required this.proposal,
    required this.federation,
    required this.inquiryChain,
    required this.error,
    this.enableFederationImport = false,
    this.onOpenImportedEntity,
    super.key,
  });

  final OmegaReadPlanePort port;
  final OmegaEntityRef entity;
  final OmegaTraceRef? trace;
  final OmegaPromotionProposal? proposal;
  final OmegaFederationBundle? federation;
  final OmegaInquiryChain? inquiryChain;
  final Object? error;
  final bool enableFederationImport;
  final Future<void> Function(BuildContext context, String entityId)?
      onOpenImportedEntity;

  @override
  State<OmegaEntityInspectorBody> createState() => _OmegaEntityInspectorBodyState();
}

class _OmegaEntityInspectorBodyState extends State<OmegaEntityInspectorBody> {
  final _inputController = TextEditingController();
  final _conflictReasonController = TextEditingController();
  String? _inquiryProposalMessage;
  String? _conflictProposalMessage;
  String? _federationImportMessage;
  OmegaFederationReceiveResult? _lastFederationImportResult;
  bool _proposing = false;
  bool _proposingConflict = false;
  bool _importingFederation = false;

  @override
  void dispose() {
    _inputController.dispose();
    _conflictReasonController.dispose();
    super.dispose();
  }

  String? get _proposeStep => OmegaInquiryLogic.proposeStep(widget.inquiryChain);

  Future<void> _proposeInquiryStep() async {
    final chain = widget.inquiryChain;
    final step = _proposeStep;
    if (chain == null || step == null) return;

    final input = _inputController.text.trim();
    if (step != 'experiment' && input.isEmpty) {
      setState(() => _inquiryProposalMessage = 'Input required.');
      return;
    }

    setState(() {
      _proposing = true;
      _inquiryProposalMessage = null;
    });

    try {
      final request = OmegaInquiryLogic.buildAdvanceRequest(
        chain: chain,
        step: step,
        input: input,
      );
      if (request == null) throw StateError('unsupported step');
      final result = await widget.port.proposeInquiryAdvance(request);
      if (!mounted) return;
      setState(() {
        _inquiryProposalMessage =
            '${result.accepted ? "Accepted" : "Rejected"}: ${result.message}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _inquiryProposalMessage = 'Propose failed: $error');
    } finally {
      if (mounted) setState(() => _proposing = false);
    }
  }

  Future<void> _importFederationFromClipboard() async {
    setState(() {
      _importingFederation = true;
      _federationImportMessage = null;
    });
    try {
      final bundle = await clipboardJsonObject();
      if (bundle == null) {
        setState(() => _federationImportMessage = 'Clipboard empty or not JSON object.');
        return;
      }
      final result = await widget.port.receiveFederationBundle(bundle);
      if (!mounted) return;
      setState(() {
        _lastFederationImportResult = result;
        _federationImportMessage =
            '${result.accepted ? "Accepted" : "Rejected"}: ${result.message}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _federationImportMessage = 'Import failed: $error');
    } finally {
      if (mounted) setState(() => _importingFederation = false);
    }
  }

  Future<void> _openImportedEntity() async {
    final entityId = _lastFederationImportResult?.entityId;
    final opener = widget.onOpenImportedEntity;
    if (entityId == null || opener == null || !mounted) return;
    Navigator.of(context).pop();
    await opener(context, entityId);
  }

  Future<void> _proposeConflict(String resolution) async {
    final reason = _conflictReasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _conflictProposalMessage = 'Reason required.');
      return;
    }
    setState(() {
      _proposingConflict = true;
      _conflictProposalMessage = null;
    });
    try {
      final result = await widget.port.proposeConflictResolution(
        OmegaConflictProposeRequest(
          conflictId: widget.entity.entityId,
          resolution: resolution,
          reason: reason,
        ),
      );
      if (!mounted) return;
      setState(() {
        _conflictProposalMessage =
            '${result.accepted ? "Accepted" : "Rejected"}: ${result.message}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _conflictProposalMessage = 'Propose failed: $error');
    } finally {
      if (mounted) setState(() => _proposingConflict = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = formatOmegaInspectorLines(
      headerLine: widget.entity.headerLine,
      trace: widget.trace,
      proposal: widget.proposal,
      federation: widget.federation,
      inquiryChain: widget.inquiryChain,
      error: widget.error,
    );
    final proposeStep = _proposeStep;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(lines.join('\n\n')),
          if (proposeStep != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            Text(
              OmegaInquiryLogic.proposeTitle(proposeStep),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: OmegaInquiryLogic.inputLabel(proposeStep),
                isDense: true,
              ),
              maxLines: 2,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _proposing ? null : _proposeInquiryStep,
                child: Text(_proposing ? 'Proposing…' : 'Propose'),
              ),
            ),
            if (_inquiryProposalMessage != null)
              Text(_inquiryProposalMessage!, style: const TextStyle(fontSize: 11)),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const Text(
            'Propose conflict resolution (dry-run)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _conflictReasonController,
            decoration: const InputDecoration(
              labelText: 'Resolution reason',
              isDense: true,
            ),
            maxLines: 2,
          ),
          Wrap(
            spacing: 4,
            children: [
              for (final resolution in ['defer', 'left_wins', 'right_wins'])
                TextButton(
                  onPressed:
                      _proposingConflict ? null : () => _proposeConflict(resolution),
                  child: Text(resolution),
                ),
            ],
          ),
          if (_conflictProposalMessage != null)
            Text(_conflictProposalMessage!, style: const TextStyle(fontSize: 11)),
          if (widget.enableFederationImport && widget.error == null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _importingFederation ? null : _importFederationFromClipboard,
              child: Text(
                _importingFederation
                    ? 'Importing…'
                    : 'Import clipboard federation bundle',
              ),
            ),
            if (_federationImportMessage != null)
              Text(_federationImportMessage!, style: const TextStyle(fontSize: 11)),
            if (_lastFederationImportResult?.accepted == true)
              TextButton(
                onPressed: _openImportedEntity,
                child: const Text('Open imported entity'),
              ),
          ],
        ],
      ),
    );
  }
}

/// Material dialog actions for federation export + entity id copy.
List<Widget> omegaEntityInspectorMaterialActions({
  required BuildContext context,
  required String entityId,
  OmegaFederationBundle? federation,
}) {
  return [
    if (federation != null && federation.allowed)
      TextButton(
        onPressed: () {
          Clipboard.setData(
            ClipboardData(
              text: const JsonEncoder.withIndent('  ').convert(
                federation.toShareJson(),
              ),
            ),
          );
          Navigator.of(context).pop();
        },
        child: const Text('Copy federation bundle'),
      ),
    TextButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: entityId));
        Navigator.of(context).pop();
      },
      child: const Text('Copy entity id'),
    ),
    TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('OK'),
    ),
  ];
}

/// Cupertino dialog actions for federation export + entity id copy.
List<Widget> omegaEntityInspectorCupertinoActions({
  required BuildContext context,
  required String entityId,
  OmegaFederationBundle? federation,
}) {
  return [
    if (federation != null && federation.allowed)
      CupertinoDialogAction(
        onPressed: () {
          Clipboard.setData(
            ClipboardData(
              text: const JsonEncoder.withIndent('  ').convert(
                federation.toShareJson(),
              ),
            ),
          );
          Navigator.of(context).pop();
        },
        child: const Text('Copy federation bundle'),
      ),
    CupertinoDialogAction(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: entityId));
        Navigator.of(context).pop();
      },
      child: const Text('Copy entity id'),
    ),
    CupertinoDialogAction(
      isDefaultAction: true,
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('OK'),
    ),
  ];
}
