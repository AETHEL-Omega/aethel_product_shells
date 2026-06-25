import 'package:flutter/material.dart';

import '../logic/omega_clipboard.dart';
import '../models/omega_read_models.dart';
import '../port/omega_read_plane_port.dart';

/// Shared Ω workspace panel content (Material). Wrap in AlertDialog or CupertinoAlertDialog.
class OmegaWorkspacePanelBody extends StatefulWidget {
  const OmegaWorkspacePanelBody({
    required this.port,
    required this.reachable,
    required this.productActor,
    required this.initialQuery,
    required this.onOpenEntity,
    super.key,
  });

  final OmegaReadPlanePort port;
  final bool reachable;
  final String productActor;
  final String initialQuery;
  final Future<void> Function(BuildContext context, String entityId) onOpenEntity;

  @override
  State<OmegaWorkspacePanelBody> createState() => _OmegaWorkspacePanelBodyState();
}

class _OmegaWorkspacePanelBodyState extends State<OmegaWorkspacePanelBody> {
  late final TextEditingController _queryController;
  late final TextEditingController _questionController;
  OmegaWorkspaceMeta? _workspace;
  OmegaScienceStatus? _science;
  List<OmegaEvidenceRef> _evidence = const [];
  bool _loading = true;
  bool _searching = false;
  bool _proposingQuestion = false;
  String? _error;
  String? _federationMessage;
  String? _inquiryProposalMessage;
  OmegaFederationReceiveResult? _lastFederationResult;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
    _questionController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _openFederationInspector() async {
    final entityId = _lastFederationResult?.entityId;
    if (entityId == null || !mounted) return;
    Navigator.of(context).pop();
    await widget.onOpenEntity(context, entityId);
  }

  Future<void> _validateClipboardBundle() async {
    if (!widget.reachable) return;
    setState(() {
      _error = null;
      _federationMessage = null;
      _lastFederationResult = null;
    });
    try {
      final bundle = await clipboardJsonObject();
      if (bundle == null) {
        setState(() => _federationMessage = 'Clipboard empty or not JSON object.');
        return;
      }
      final result = await widget.port.receiveFederationBundle(bundle);
      if (!mounted) return;
      setState(() {
        _lastFederationResult = result;
        _federationMessage =
            '${result.accepted ? "Accepted" : "Rejected"}: ${result.message}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _federationMessage = 'Validate failed: $error');
    }
  }

  Future<void> _proposeQuestion() async {
    if (!widget.reachable) return;
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      setState(() => _inquiryProposalMessage = 'Question required.');
      return;
    }
    setState(() {
      _proposingQuestion = true;
      _inquiryProposalMessage = null;
    });
    try {
      final result = await widget.port.proposeInquiryAdvance(
        OmegaInquiryAdvanceRequest(
          step: 'question',
          payload: {'question': question},
        ),
      );
      if (!mounted) return;
      setState(() {
        _inquiryProposalMessage =
            '${result.accepted ? "Accepted" : "Rejected"}: ${result.message}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _inquiryProposalMessage = 'Propose failed: $error');
    } finally {
      if (mounted) setState(() => _proposingQuestion = false);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.reachable) {
        _workspace = await widget.port.fetchWorkspaceMeta(forceRefresh: true);
        _science = await widget.port.fetchScienceStatus();
        await _search();
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (!widget.reachable || query.isEmpty) {
      setState(() => _evidence = const []);
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final items = await widget.port.searchEvidence(
        OmegaEvidenceQuery(q: query, limit: 8),
      );
      if (!mounted) return;
      setState(() => _evidence = items);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _evidence = const [];
        _error = error.toString();
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            [
              'Actor: ${widget.productActor}',
              'API: ${widget.reachable ? "reachable" : "offline"}',
              if (_workspace != null) ...[
                'Source: ${_workspace!.sourceSpaceId}',
                'Welt: ${_workspace!.weltSpaceId}',
                'DIN: ${_workspace!.dinSpaceId}',
              ],
              if (_science != null)
                'Science atlas: ${_science!.nodes} nodes, '
                '${_science!.edges} edges, '
                '${_science!.taxonomyConcepts} concepts',
              if (_workspace == null && widget.reachable) 'Workspace meta unavailable',
              if (_error != null) 'Error: $_error',
            ].join('\n'),
            style: const TextStyle(fontFamily: 'Menlo', fontSize: 11),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _queryController,
            decoration: const InputDecoration(
              labelText: 'Evidence search',
              isDense: true,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _searching ? null : _search,
              child: Text(_searching ? 'Searching…' : 'Search'),
            ),
          ),
          if (widget.reachable) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _validateClipboardBundle,
                child: const Text('Validate clipboard bundle'),
              ),
            ),
            if (_federationMessage != null)
              Text(_federationMessage!, style: const TextStyle(fontSize: 11)),
            if (_lastFederationResult?.accepted == true)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _openFederationInspector,
                  child: const Text('Open entity inspector'),
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Propose inquiry question (dry-run)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'New question',
                isDense: true,
              ),
              maxLines: 2,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _proposingQuestion ? null : _proposeQuestion,
                child: Text(_proposingQuestion ? 'Proposing…' : 'Propose'),
              ),
            ),
            if (_inquiryProposalMessage != null)
              Text(_inquiryProposalMessage!, style: const TextStyle(fontSize: 11)),
          ],
          if (_evidence.isNotEmpty) ...[
            const Divider(),
            for (final ref in _evidence)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(ref.label, style: const TextStyle(fontSize: 12)),
                subtitle: Text(
                  '${ref.stageLabel} · ${ref.entityId.length >= 8 ? ref.entityId.substring(0, 8) : ref.entityId}',
                  style: const TextStyle(fontSize: 11),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onOpenEntity(context, ref.entityId);
                },
              ),
          ] else if (_queryController.text.trim().isNotEmpty && !_searching)
            const Text('No evidence matches.', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          const Text(
            'Read-only shell. Evidence is not canonical truth.',
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
