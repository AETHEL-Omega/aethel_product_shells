# TEST-CASES — aethel_product_shells

Jeder Testfall `TC-NNN` deckt mindestens eine Requirement aus [SPEC.md](SPEC.md) ab.
Automatisierte Tests liegen unter `test/` (Flutter-Konvention `*_test.dart`).
Status-Legende: ✅ automatisiert · ⬜ offen (noch kein Test) · 🔎 per Code-Review/Quelle belegt.

| ID | deckt ab | Given | When | Then | Test / Status |
|------|---|---|---|---|---|
| TC-001 | REQ-005 | Offene Inquiry-Chain (`status='open'`) ohne Hypothesen/Experimente/Ergebnisse | `OmegaInquiryLogic.proposeStep(chain)` | liefert `'hypothesis'` | ✅ `test/omega_inquiry_logic_test.dart` › "proposeStep returns hypothesis when chain is open" |
| TC-002 | REQ-006 | Offene Chain mit `questionId='q1'` | `buildAdvanceRequest(step:'hypothesis', input:'Yes it does')` | `step=='hypothesis'` und `payload['statement']=='Yes it does'` | ✅ `test/omega_inquiry_logic_test.dart` › "buildAdvanceRequest creates hypothesis payload" |
| TC-003 | REQ-007 | Zwei Library-Knoten mit Stages `omega0_signal` und `inquiry` | `OmegaLibraryGraph.groupByStage(nodes)` | `grouped['inquiry']` und `grouped['omega0_signal']` haben je Länge 1 | ✅ `test/omega_library_graph_test.dart` › "groups nodes by omega receipt stage" |
| TC-004 | REQ-008 | Ein lokaler Treffer + eine Remote-Evidenz mit anderer `entityId`, `limit:4` | `OmegaLibraryGraph.mergeEvidence(...)` | erstes Element ist der lokale Knoten, Gesamtlänge 2 | ✅ `test/omega_library_graph_test.dart` › "merges local library matches before remote evidence" |
| TC-005 | REQ-009, REQ-010 | Stub-Port liefert eine Remote-Evidenz; ein lokaler Library-Knoten "Merge sort notes"; Query "merge sort" | `AssistantOmegaEvidence.buildPromptBlock(...)` | Block enthält "Omega evidence set", `omega:<lokale entityId>` und "not canonical truth" | ✅ `test/assistant_omega_evidence_test.dart` › "builds bounded prompt block with local-first evidence" |
| TC-006 | REQ-012 | Eine Evidenz mit navigierbarer URI, `seenUrlKeysLower` ohne deren Key | `OmnibarOmegaEvidence.suggestionsFromEvidence(...)` | genau 1 Vorschlag; `entityId` übernommen; Subtitle enthält "Ω Evidence" | ✅ `test/omnibar_omega_evidence_test.dart` › "appends navigable evidence suggestions" |
| TC-007 | REQ-011, REQ-012 | Eine Evidenz mit bereits gesehener URL + eine Evidenz ohne URI | `suggestionsFromEvidence(...)` | Ergebnis ist leer (Duplikat verworfen, URI-lose übersprungen) | ✅ `test/omnibar_omega_evidence_test.dart` › "skips evidence without navigable uri and dedupes urls" |
| TC-008 | REQ-011 | URLs `javascript:alert(1)` und `https://example.com` | `OmegaNavigableUrl.isNavigable(url)` | `false` bzw. `true` | ✅ `test/omnibar_omega_evidence_test.dart` › "rejects non-http schemes" |
| TC-009 | REQ-001 | Konsument importiert nur das Barrel | `import 'package:aethel_product_shells/aethel_product_shells.dart'` | alle in den Tests genutzten Symbole (Port, Modelle, Logik) sind auflösbar (kompiliert) | 🔎 implizit durch alle `test/*_test.dart` (Single-Import) |
| TC-010 | REQ-002 | `aethel_product_shells.dart` | Barrel-Export wird kompiliert | `OmegaReadPlanePort` ist als abstraktes Interface mit 11 Methoden exportiert, ohne konkrete Implementierung | 🔎 `lib/src/port/omega_read_plane_port.dart` |
| TC-011 | REQ-004 | `OmegaEvidenceRef` mit `epistemicStage='omega0_signal'` bzw. `'omega6_verified_knowledge'` | `ref.stageLabel` | "Signal" bzw. "Verified"; unbekannte Stage ⇒ Rohwert/`kind` | ⬜ offen (Logik in `omega_read_models.dart`) |
| TC-012 | REQ-003 | JSON ohne `workspace`-Objekt | `OmegaWorkspaceMeta.fromJson(json)` | wirft `FormatException` | ⬜ offen (`omega_read_models.dart`) |
| TC-013 | REQ-014 | `OmegaFederationBundle` mit Evidenz und Trace | `bundle.toShareJson()` | enthält `schema_version='aethel.omega_federation_bundle.v0'`, UTC-ISO8601 `exportedAt`, `source:'omega'` auf Bundle/Trace/Evidenz | ⬜ offen (`omega_read_models.dart`) |
| TC-014 | REQ-013 | `formatOmegaInspectorLines(headerLine:'h', error: Exception())` ohne Trace | Aufruf | erste Zeile `'h'`, enthält "Trace: none recorded" und "Ω read-plane unavailable" | ⬜ offen (`omega_inspector_format.dart`) |
| TC-015 | REQ-015 | Zwischenablage enthält Nicht-JSON-Text bzw. ein JSON-Objekt | `clipboardJsonObject()` | `null` bzw. `Map<String,Object?>` mit string-Keys | ⬜ offen (benötigt Clipboard-Mock) |
| TC-016 | REQ-016 | `OmegaWorkspacePanelBody` mit `reachable:false` | Widget rendert | Bootstrap-Hinweis sichtbar, keine Remote-Calls; Fußzeile "Evidence is not canonical truth" | 🔎 `lib/src/widgets/omega_workspace_panel_body.dart` (Widget-Test offen) |
| TC-017 | REQ-017 | `OmegaEntityInspectorBody` mit geschlossener/`null`-Chain | Widget rendert | kein Propose-Block; Konflikt-Resolution ohne Grund ⇒ "Reason required." | 🔎 `lib/src/widgets/omega_entity_inspector_body.dart` (Widget-Test offen) |
| TC-018 | REQ-018 | `OmegaTraceRef` mit 36-Zeichen-`traceId` | `trace.shortTraceId` | erste 8 Zeichen | ⬜ offen (`omega_read_models.dart`) |
| TC-019 | REQ-019 | Quellbaum `lib/` | Suche nach `OmegaIngestReceipt`/`OmegaNodeReceipt` | kein Treffer (Typen bleiben im Produkt) | 🔎 belegt (kein Vorkommen in `lib/`) |
| TC-020 | REQ-020 | Reine Logik-Klassen | Aufruf in Unit-Tests ohne Widget-Tree | funktionieren ohne `WidgetTester` (siehe TC-001…TC-008) | 🔎 belegt durch bestehende Tests |

## Abdeckungs-Matrix

Ziel: jede `MUST`-Requirement hat ≥ 1 Testfall. Spalte "Auto" = mind. ein automatisierter (✅) Test.

| Requirement | Prio | Testfälle | Auto |
|---|:--:|---|:--:|
| REQ-001 | MUST | TC-009 | 🔎 |
| REQ-002 | MUST | TC-010 | 🔎 |
| REQ-003 | MUST | TC-012 | ⬜ |
| REQ-004 | MUST | TC-011 | ⬜ |
| REQ-005 | MUST | TC-001 | ✅ |
| REQ-006 | MUST | TC-002 | ✅ |
| REQ-007 | MUST | TC-003 | ✅ |
| REQ-008 | MUST | TC-004 | ✅ |
| REQ-009 | MUST | TC-005 | ✅ |
| REQ-010 | MUST | TC-005 | ✅ |
| REQ-011 | MUST | TC-007, TC-008 | ✅ |
| REQ-012 | MUST | TC-006, TC-007 | ✅ |
| REQ-013 | MUST | TC-014 | ⬜ |
| REQ-014 | MUST | TC-013 | ⬜ |
| REQ-015 | MUST | TC-015 | ⬜ |
| REQ-016 | MUST | TC-016 | 🔎 |
| REQ-017 | MUST | TC-017 | 🔎 |
| REQ-018 | SHOULD | TC-018 | ⬜ |
| REQ-019 | SHOULD | TC-019 | 🔎 |
| REQ-020 | SHOULD | TC-020 | 🔎 |

Offene Lücken (Ausbau-Backlog): TC-011…TC-015 (Modell-/Format-/Clipboard-Units)
und TC-016/TC-017 (Widget-Tests) sind spezifiziert, aber noch nicht automatisiert.
8 von 8 reine-Logik-Verträge der Slices P57–P59 sind automatisiert grün.
