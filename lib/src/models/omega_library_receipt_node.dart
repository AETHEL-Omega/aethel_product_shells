import 'package:meta/meta.dart';

/// Minimal library node with an Ω receipt for graph grouping (product shells).
@immutable
class OmegaLibraryReceiptNode {
  const OmegaLibraryReceiptNode({
    required this.title,
    required this.url,
    required this.entityId,
    required this.epistemicStage,
    required this.lastSeen,
  });

  final String title;
  final String url;
  final String entityId;
  final String epistemicStage;
  final DateTime lastSeen;

  String get displayLabel => title.isNotEmpty ? title : url;
}
