import 'package:meta/meta.dart';

@immutable
class OmegaWorkspaceMeta {
  const OmegaWorkspaceMeta({
    required this.sourceSpaceId,
    required this.weltSpaceId,
    required this.dinSpaceId,
  });

  factory OmegaWorkspaceMeta.fromJson(Map<String, dynamic> json) {
    final workspace = json['workspace'];
    if (workspace is! Map) {
      throw FormatException('Missing workspace object');
    }
    final map = Map<String, dynamic>.from(workspace);
    return OmegaWorkspaceMeta(
      sourceSpaceId: map['sourceSpaceId'] as String,
      weltSpaceId: map['weltSpaceId'] as String,
      dinSpaceId: map['dinSpaceId'] as String,
    );
  }

  final String sourceSpaceId;
  final String weltSpaceId;
  final String dinSpaceId;
}

@immutable
class OmegaScienceStatus {
  const OmegaScienceStatus({
    required this.nodes,
    required this.edges,
    required this.taxonomyConcepts,
    required this.entityAnchors,
    required this.graphEntityRefs,
  });

  factory OmegaScienceStatus.fromJson(Map<String, dynamic> json) {
    final science = json['science'];
    if (science is! Map) {
      throw FormatException('Missing science object');
    }
    final map = Map<String, dynamic>.from(science);
    return OmegaScienceStatus(
      nodes: (map['nodes'] as num).toInt(),
      edges: (map['edges'] as num).toInt(),
      taxonomyConcepts: (map['taxonomyConcepts'] as num).toInt(),
      entityAnchors: (map['entityAnchors'] as num).toInt(),
      graphEntityRefs: (map['graphEntityRefs'] as num).toInt(),
    );
  }

  final int nodes;
  final int edges;
  final int taxonomyConcepts;
  final int entityAnchors;
  final int graphEntityRefs;
}

@immutable
class OmegaEvidenceRef {
  const OmegaEvidenceRef({
    required this.entityId,
    required this.label,
    required this.kind,
    this.epistemicStage,
    this.uri,
  });

  factory OmegaEvidenceRef.fromJson(Map<String, dynamic> json) {
    return OmegaEvidenceRef(
      entityId: json['entityId'] as String,
      label: json['label'] as String,
      kind: json['kind'] as String,
      epistemicStage: json['epistemicStage'] as String?,
      uri: json['uri'] as String?,
    );
  }

  final String entityId;
  final String label;
  final String kind;
  final String? epistemicStage;
  final String? uri;

  String get stageLabel {
    switch (epistemicStage) {
      case 'omega0_signal':
        return 'Signal';
      case 'omega6_verified_knowledge':
        return 'Verified';
      default:
        return epistemicStage ?? kind;
    }
  }
}

@immutable
class OmegaEvidenceQuery {
  const OmegaEvidenceQuery({
    required this.q,
    this.limit = 5,
    this.kind,
  });

  final String q;
  final int limit;
  final String? kind;
}

@immutable
class OmegaTraceRef {
  const OmegaTraceRef({
    required this.traceId,
    required this.mutation,
    required this.outcome,
    required this.recordedAt,
    this.message,
  });

  factory OmegaTraceRef.fromJson(Map<String, dynamic> json) {
    return OmegaTraceRef(
      traceId: json['traceId'] as String,
      mutation: json['mutation'] as String,
      outcome: json['outcome'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      message: json['message'] as String?,
    );
  }

  final String traceId;
  final String mutation;
  final String outcome;
  final DateTime recordedAt;
  final String? message;

  String get shortTraceId =>
      traceId.length >= 8 ? traceId.substring(0, 8) : traceId;
}

@immutable
class OmegaInquiryChainNode {
  const OmegaInquiryChainNode({
    required this.entityId,
    required this.kind,
    required this.label,
    this.status,
  });

  factory OmegaInquiryChainNode.fromJson(Map<String, dynamic> json) {
    return OmegaInquiryChainNode(
      entityId: json['entityId'] as String,
      kind: json['kind'] as String,
      label: json['label'] as String,
      status: json['status'] as String?,
    );
  }

  final String entityId;
  final String kind;
  final String label;
  final String? status;
}

@immutable
class OmegaInquiryChain {
  const OmegaInquiryChain({
    required this.questionId,
    required this.question,
    required this.status,
    required this.hypotheses,
    required this.experiments,
    required this.results,
  });

  factory OmegaInquiryChain.fromJson(Map<String, dynamic> json) {
    List<OmegaInquiryChainNode> nodes(String key) {
      final items = json[key];
      if (items is! List) return const [];
      return items
          .whereType<Map>()
          .map((item) => OmegaInquiryChainNode.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }

    return OmegaInquiryChain(
      questionId: json['questionId'] as String,
      question: json['question'] as String,
      status: json['status'] as String,
      hypotheses: nodes('hypotheses'),
      experiments: nodes('experiments'),
      results: nodes('results'),
    );
  }

  final String questionId;
  final String question;
  final String status;
  final List<OmegaInquiryChainNode> hypotheses;
  final List<OmegaInquiryChainNode> experiments;
  final List<OmegaInquiryChainNode> results;
}

@immutable
class OmegaMembraneCheck {
  const OmegaMembraneCheck({
    required this.law,
    required this.name,
    required this.passed,
    this.message,
  });

  factory OmegaMembraneCheck.fromJson(Map<String, dynamic> json) {
    return OmegaMembraneCheck(
      law: json['law'] as String,
      name: json['name'] as String,
      passed: json['passed'] as bool,
      message: json['message'] as String?,
    );
  }

  final String law;
  final String name;
  final bool passed;
  final String? message;
}

@immutable
class OmegaPromotionProposal {
  const OmegaPromotionProposal({
    required this.entityId,
    required this.fromLayer,
    required this.toLayer,
    required this.wouldAccept,
    required this.message,
    required this.membranePassed,
    required this.eligibleForCanonical,
    required this.checks,
  });

  factory OmegaPromotionProposal.fromJson(Map<String, dynamic> json) {
    final checks = json['checks'];
    return OmegaPromotionProposal(
      entityId: json['entityId'] as String,
      fromLayer: json['fromLayer'] as String,
      toLayer: json['toLayer'] as String,
      wouldAccept: json['wouldAccept'] as bool,
      message: json['message'] as String,
      membranePassed: json['membranePassed'] as bool,
      eligibleForCanonical: json['eligibleForCanonical'] as bool,
      checks: checks is List
          ? checks
              .whereType<Map>()
              .map((c) => OmegaMembraneCheck.fromJson(Map<String, dynamic>.from(c)))
              .toList(growable: false)
          : const [],
    );
  }

  final String entityId;
  final String fromLayer;
  final String toLayer;
  final bool wouldAccept;
  final String message;
  final bool membranePassed;
  final bool eligibleForCanonical;
  final List<OmegaMembraneCheck> checks;
}

@immutable
class OmegaFederationBundle {
  const OmegaFederationBundle({
    required this.schemaVersion,
    required this.exportedAt,
    required this.federationScope,
    required this.entityId,
    required this.allowed,
    this.message,
    this.receipt,
    this.trace,
    this.evidence = const [],
    this.redactions = const [],
  });

  static const schemaVersionValue = 'aethel.omega_federation_bundle.v0';

  factory OmegaFederationBundle.fromJson(Map<String, dynamic> json) {
    final bundle = json['bundle'];
    if (bundle is! Map) {
      throw FormatException('Missing federation bundle');
    }
    final map = Map<String, dynamic>.from(bundle);
    final evidence = map['evidence'];
    final redactions = map['redactions'];
    final receipt = map['receipt'];
    final trace = map['trace'];
    return OmegaFederationBundle(
      schemaVersion: map['schema_version'] as String? ?? schemaVersionValue,
      exportedAt: DateTime.parse(map['exportedAt'] as String),
      federationScope: map['federationScope'] as String,
      entityId: map['entityId'] as String,
      allowed: map['allowed'] as bool,
      message: map['message'] as String?,
      receipt: receipt is Map
          ? OmegaFederationReceipt.fromJson(Map<String, dynamic>.from(receipt))
          : null,
      trace: trace is Map
          ? OmegaTraceRef.fromJson(Map<String, dynamic>.from(trace))
          : null,
      evidence: evidence is List
          ? evidence
              .whereType<Map>()
              .map((item) => OmegaEvidenceRef.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const [],
      redactions: redactions is List
          ? redactions.map((item) => item.toString()).toList(growable: false)
          : const [],
    );
  }

  final String schemaVersion;
  final DateTime exportedAt;
  final String federationScope;
  final String entityId;
  final bool allowed;
  final String? message;
  final OmegaFederationReceipt? receipt;
  final OmegaTraceRef? trace;
  final List<OmegaEvidenceRef> evidence;
  final List<String> redactions;

  Map<String, Object?> toShareJson() => {
        'schema_version': schemaVersion,
        'exportedAt': exportedAt.toUtc().toIso8601String(),
        'federationScope': federationScope,
        'entityId': entityId,
        'allowed': allowed,
        if (message != null) 'message': message,
        if (receipt != null) 'receipt': receipt!.toJson(),
        if (trace != null)
          'trace': {
            'traceId': trace!.traceId,
            'mutation': trace!.mutation,
            'outcome': trace!.outcome,
            'recordedAt': trace!.recordedAt.toUtc().toIso8601String(),
            if (trace!.message != null) 'message': trace!.message,
            'source': 'omega',
          },
        'evidence': [
          for (final item in evidence)
            {
              'entityId': item.entityId,
              'label': item.label,
              'kind': item.kind,
              if (item.epistemicStage != null) 'epistemicStage': item.epistemicStage,
              if (item.uri != null) 'uri': item.uri,
              'source': 'omega',
            },
        ],
        'redactions': redactions,
        'source': 'omega',
      };
}

@immutable
class OmegaFederationReceipt {
  const OmegaFederationReceipt({
    required this.entityId,
    required this.recordedAt,
    this.dinTraceId,
    this.epistemicStage,
  });

  factory OmegaFederationReceipt.fromJson(Map<String, dynamic> json) {
    return OmegaFederationReceipt(
      entityId: json['entityId'] as String,
      dinTraceId: json['dinTraceId'] as String?,
      epistemicStage: json['epistemicStage'] as String?,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  final String entityId;
  final String? dinTraceId;
  final String? epistemicStage;
  final DateTime recordedAt;

  Map<String, Object?> toJson() => {
        'entityId': entityId,
        if (dinTraceId != null) 'dinTraceId': dinTraceId,
        if (epistemicStage != null) 'epistemicStage': epistemicStage,
        'recordedAt': recordedAt.toUtc().toIso8601String(),
        'source': 'omega',
      };
}
@immutable
class OmegaFederationReceiveResult {
  const OmegaFederationReceiveResult({
    required this.accepted,
    required this.message,
    required this.entityId,
    required this.foreignEntity,
    required this.evidenceCount,
  });

  factory OmegaFederationReceiveResult.fromJson(Map<String, dynamic> json) {
    final item = json['item'];
    if (item is! Map) {
      throw FormatException('Missing federation receive item');
    }
    final map = Map<String, dynamic>.from(item);
    return OmegaFederationReceiveResult(
      accepted: map['accepted'] as bool,
      message: map['message'] as String,
      entityId: map['entityId'] as String,
      foreignEntity: map['foreignEntity'] as bool,
      evidenceCount: (map['evidenceCount'] as num).toInt(),
    );
  }

  final bool accepted;
  final String message;
  final String entityId;
  final bool foreignEntity;
  final int evidenceCount;
}

@immutable
class OmegaInquiryAdvanceRequest {
  const OmegaInquiryAdvanceRequest({
    required this.step,
    required this.payload,
    this.questionId,
    this.hypothesisId,
    this.experimentId,
  });

  final String step;
  final Map<String, Object?> payload;
  final String? questionId;
  final String? hypothesisId;
  final String? experimentId;

  Map<String, Object?> toJson() => {
        'step': step,
        'payload': payload,
        if (questionId != null) 'questionId': questionId,
        if (hypothesisId != null) 'hypothesisId': hypothesisId,
        if (experimentId != null) 'experimentId': experimentId,
      };
}

@immutable
class OmegaInquiryProposal {
  const OmegaInquiryProposal({
    required this.accepted,
    required this.step,
    required this.message,
    this.wouldCreateKind,
  });

  factory OmegaInquiryProposal.fromJson(Map<String, dynamic> json) {
    final item = json['item'];
    if (item is! Map) {
      throw FormatException('Missing inquiry proposal item');
    }
    final map = Map<String, dynamic>.from(item);
    return OmegaInquiryProposal(
      accepted: map['accepted'] as bool,
      step: map['step'] as String,
      message: map['message'] as String,
      wouldCreateKind: map['wouldCreateKind'] as String?,
    );
  }

  final bool accepted;
  final String step;
  final String message;
  final String? wouldCreateKind;
}

@immutable
class OmegaConflictProposeRequest {
  const OmegaConflictProposeRequest({
    required this.conflictId,
    required this.resolution,
    required this.reason,
    this.supersedeLoser,
  });

  final String conflictId;
  final String resolution;
  final String reason;
  final bool? supersedeLoser;

  Map<String, Object?> toJson() => {
        'conflictId': conflictId,
        'resolution': resolution,
        'reason': reason,
        if (supersedeLoser != null) 'supersedeLoser': supersedeLoser,
      };
}

@immutable
class OmegaConflictProposal {
  const OmegaConflictProposal({
    required this.accepted,
    required this.conflictId,
    required this.message,
    this.resolution,
    this.winnerEntityId,
    this.loserEntityId,
    this.wouldSupersede,
  });

  factory OmegaConflictProposal.fromJson(Map<String, dynamic> json) {
    final item = json['item'];
    if (item is! Map) {
      throw FormatException('Missing conflict proposal item');
    }
    final map = Map<String, dynamic>.from(item);
    return OmegaConflictProposal(
      accepted: map['accepted'] as bool,
      conflictId: map['conflictId'] as String,
      message: map['message'] as String,
      resolution: map['resolution'] as String?,
      winnerEntityId: map['winnerEntityId'] as String?,
      loserEntityId: map['loserEntityId'] as String?,
      wouldSupersede: map['wouldSupersede'] as bool?,
    );
  }

  final bool accepted;
  final String conflictId;
  final String message;
  final String? resolution;
  final String? winnerEntityId;
  final String? loserEntityId;
  final bool? wouldSupersede;
}

@immutable
class OmegaEntityRef {
  const OmegaEntityRef({
    required this.entityId,
    this.epistemicStage,
    this.headerPrefix = 'Signal',
  });

  final String entityId;
  final String? epistemicStage;
  final String headerPrefix;

  String get headerLine {
    final stage = epistemicStage;
    if (stage == null) return '$headerPrefix · $entityId';
    return '${_stageLabel(stage)} · $entityId';
  }

  static String _stageLabel(String stage) {
    switch (stage) {
      case 'omega0_signal':
        return 'Signal';
      case 'omega1_observation':
        return 'Observation';
      case 'inquiry':
        return 'Inquiry';
      default:
        return stage;
    }
  }
}
