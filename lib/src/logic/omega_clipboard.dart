import 'dart:convert';

import 'package:flutter/services.dart';

Future<Map<String, Object?>?> clipboardJsonObject() async {
  final clip = await Clipboard.getData(Clipboard.kTextPlain);
  final raw = clip?.text?.trim() ?? '';
  if (raw.isEmpty) return null;
  final decoded = jsonDecode(raw);
  if (decoded is! Map) return null;
  return Map<String, Object?>.from(
    decoded.map((key, value) => MapEntry(key.toString(), value)),
  );
}
