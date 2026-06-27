# SPEC — aethel_product_shells

Status: aktiv · Version 0.1.4 · letzte Pflege 2026-06-27

## Problem

`aethelBrowser` und `aethelTerminal` brauchen beide dieselbe Lese-Ebenen-UI über
die AETHEL-Ω-Wissensbasis (Read-Plane): Evidenz suchen, Entitäten inspizieren,
Inquiry-/Konflikt-/Promotion-/Föderations-Vorschläge als Dry-Run stellen. Würde
jedes Produkt diese Modelle, Logik und Widgets eigenständig pflegen, driften
JSON-Verträge, Stage-Beschriftungen und Sicherheitsregeln (z. B. "nur navigierbare
URLs", "Evidenz ist keine kanonische Wahrheit") auseinander.

## Lösung

Ein Flutter-Paket (`publish_to: none`, per Git-`ref` oder lokalem `path`
konsumiert) liefert die geteilte Read-Plane-Schicht:

- **Port** `OmegaReadPlanePort` — ein abstraktes HTTP-Interface; jedes Produkt
  implementiert seinen eigenen Transport.
- **Modelle** — unveränderliche (`@immutable`) Datentypen mit `fromJson`/`toJson`
  für den Ω-Read-Plane-Vertrag.
- **Logik** — reine, UI-freie Hilfsklassen (Inquiry-Schritt-Ableitung, Library-
  Graph-Gruppierung, Assistant-Evidenz-Block, Omnibar-Vorschläge, URL-Validierung,
  Inspector-Formatierung, Clipboard-JSON).
- **Widgets** — `OmegaWorkspacePanelBody` und `OmegaEntityInspectorBody` als
  Material-Bodies zum Einbetten in Dialoge.

## Scope

- Geteilte Read-Plane-Modelle, -Logik und -Widgets für beide Produkt-Shells.
- Dry-Run-Vorschläge (Inquiry, Konflikt, Promotion, Föderation) — keine Schreib-
  Wirkung im Paket selbst; das Paket baut nur Requests und formatiert Antworten.
- Lokal-zuerst-Verschmelzung von Library-Treffern mit Remote-Evidenz.

## Non-Goals

- **Kein Transport:** Das Paket implementiert `OmegaReadPlanePort` nicht; HTTP/
  Auth liegen im Produkt.
- **Keine Browser-Ingest-Typen** (`OmegaIngestReceipt`, `OmegaNodeReceipt`) und
  keine Terminal-Session-Typen — diese bleiben in den Produkt-Repos.
- **Keine kanonische Wahrheit:** Evidenz/Ratings sind Lese-Hinweise, keine
  Verifikation; das Paket schreibt nichts in die Wissensbasis.
- **Kein Routing/Navigation:** Entitäts-Öffnen wird per Callback an das Produkt
  delegiert.

## Requirements

| ID | Prio | Anforderung | Akzeptanzkriterium |
|------|:--:|---|---|
| REQ-001 | MUST | Das Paket exportiert über `aethel_product_shells.dart` genau eine öffentliche API-Fläche (Port, Modelle, Logik, Widgets). | Konsumenten importieren nur `package:aethel_product_shells/aethel_product_shells.dart`; alle dokumentierten Symbole sind darüber erreichbar. |
| REQ-002 | MUST | `OmegaReadPlanePort` definiert den vollständigen Read/Propose-Vertrag (Reachability, Workspace-Meta, Science-Status, Evidenz-Suche, Trace, Promotion, Föderations-Export/-Empfang, Inquiry-Chain, Inquiry-Advance, Konflikt-Resolution) als abstraktes Interface. | Interface deklariert alle 11 Methoden; das Paket liefert keine konkrete Implementierung. |
| REQ-003 | MUST | Read-Plane-Modelle sind unveränderlich und parsen den Ω-JSON-Vertrag robust. | Modelle sind `@immutable`; `fromJson` wirft `FormatException` bei fehlenden Pflicht-Objekten (workspace/science/bundle/item); fehlende optionale Felder ergeben `null`/leere Listen. |
| REQ-004 | MUST | Epistemische Stage-Codes werden auf menschenlesbare Labels gemappt. | `omega0_signal`→"Signal", `omega6_verified_knowledge`→"Verified", `omega1_observation`→"Observation", `inquiry`→"Inquiry"; unbekannte Stage fällt auf Rohwert bzw. `kind` zurück. |
| REQ-005 | MUST | `OmegaInquiryLogic` leitet den nächsten offenen Inquiry-Schritt deterministisch ab. | Bei `status=='open'`: erst fehlende Hypothese→`hypothesis`, dann Experiment→`experiment`, dann Ergebnis→`result`; sonst (geschlossen oder vollständig oder `null`) `null`. |
| REQ-006 | MUST | `OmegaInquiryLogic.buildAdvanceRequest` erzeugt den korrekten Advance-Request je Schritt. | `hypothesis` setzt `questionId`+`payload.statement`; `experiment` setzt `hypothesisId`+`payload.hypothesis` (Methode optional); `result` setzt `experimentId`+`payload.finding`; unbekannter Schritt→`null`. |
| REQ-007 | MUST | `OmegaLibraryGraph.groupByStage` gruppiert Library-Knoten nach Stage in fester Reihenfolge und sortiert je Gruppe absteigend nach `lastSeen`. | Buckets `inquiry, omega0_signal, omega1_observation, other` existieren immer; unbekannte Stages landen in `other`; jede Gruppe ist nach `lastSeen` (neueste zuerst) sortiert. |
| REQ-008 | MUST | `OmegaLibraryGraph.mergeEvidence` verschmilzt lokale Treffer vor Remote-Evidenz, dedupliziert per `entityId` und respektiert das Limit. | Lokale Knoten erscheinen zuerst (als `kind:'resource'`-Refs); Remote-Refs mit bereits gesehener `entityId` werden verworfen; Ergebnislänge ≤ `limit`. |
| REQ-009 | MUST | `AssistantOmegaEvidence.buildPromptBlock` baut einen begrenzten, lokal-zuerst gefüllten Evidenz-Block für LLM-Prompts. | Block beginnt mit "Omega evidence set"-Header inkl. Hinweis "not canonical truth"; jede Zeile ist `omega:<entityId> kind=… stage=… label=…`; leerer Query oder keine Treffer ⇒ leerer String. |
| REQ-010 | MUST | `buildPromptBlock` ist gegen einen nicht erreichbaren Read-Plane robust. | Wirft `port.searchEvidence` eine Exception, wird sie geschluckt; der Block enthält dann nur lokale Treffer (oder ist leer). |
| REQ-011 | MUST | `OmegaNavigableUrl.isNavigable` lässt nur sichere, navigierbare http(s)-URLs zu. | Ablehnung von leer, `about:blank`, `javascript:`-Schemata, schemalosen/host-losen URLs, Nicht-http(s)-Schemata und DuckDuckGo-Suchlinks (`duckduckgo.com?q=`); reine http/https-URLs mit Host werden akzeptiert. |
| REQ-012 | MUST | `OmnibarOmegaEvidence.suggestionsFromEvidence` mappt Evidenz auf Omnibar-Vorschläge, filtert nicht-navigierbare URLs und dedupliziert. | Nur Refs mit navigierbarer URI werden übernommen; `dedupeKey` (lowercased URL) gegen `seenUrlKeysLower` verhindert Duplikate; Subtitle enthält "Ω Evidence · <stageLabel>"; Set wird um neue Keys ergänzt. |
| REQ-013 | MUST | `formatOmegaInspectorLines` rendert den Inspector-Text aus optionalen Read-Plane-Daten. | Erste Zeile ist `headerLine`; Trace zeigt Kurz-ID+Mutation+Outcome oder "Trace: none recorded"; Promotion zeigt `from→to` + "would pass"/"blocked"; Föderation zeigt Scope + Evidenz-Anzahl/"blocked"; Inquiry zeigt Status+Frage+Zähler; bei `error!=null` Zeile "Ω read-plane unavailable". |
| REQ-014 | MUST | Der Föderations-Export erzeugt einen stabilen, quell-getaggten Share-JSON. | `OmegaFederationBundle.toShareJson()` enthält `schema_version=aethel.omega_federation_bundle.v0`, UTC-ISO8601-`exportedAt`, `source:'omega'` (Bundle, Trace und jede Evidenz), Receipt/Trace/Redactions nur wenn vorhanden. |
| REQ-015 | MUST | `clipboardJsonObject` liest ausschließlich ein JSON-Objekt aus der Zwischenablage. | Leerer/Nicht-JSON-/Nicht-Objekt-Inhalt ⇒ `null`; ein JSON-Objekt ⇒ `Map<String,Object?>` mit string-normalisierten Keys. |
| REQ-016 | MUST | `OmegaWorkspacePanelBody` ist ein Read-Plane-Panel mit Offline-Bootstrap-Hinweis und Dry-Run-Aktionen. | Bei `reachable==false` wird ein Bootstrap-Hinweis (`pnpm knowledge:stack bootstrap`) gezeigt und keine Remote-Calls/Propose-Aktionen ausgelöst; bei `reachable==true` werden Workspace-Meta, Science-Status und Evidenz geladen; Entitäts-Tap delegiert an `onOpenEntity`; Fußzeile "Evidence is not canonical truth". |
| REQ-017 | MUST | `OmegaEntityInspectorBody` zeigt den nächsten Inquiry-Schritt nur bei offener Chain und bietet Konflikt-/Föderations-Dry-Run-Aktionen. | Propose-Block erscheint nur, wenn `OmegaInquiryLogic.proposeStep != null`; Konflikt-Resolutionen `defer/left_wins/right_wins` erfordern einen nicht-leeren Grund; Föderations-Import nur bei `enableFederationImport && error==null`; Material- und Cupertino-Dialog-Actions bieten "Copy federation bundle" (nur wenn erlaubt) und "Copy entity id". |
| REQ-018 | SHOULD | Kurz-Bezeichner werden für die UI gekappt. | `OmegaTraceRef.shortTraceId` und Entitäts-IDs in der Anzeige sind auf 8 Zeichen gekürzt (kürzere Werte unverändert). |
| REQ-019 | SHOULD | Das Paket trägt keine Produkt-spezifischen Ingest-/Session-Typen. | Quellbaum unter `lib/` enthält keine `OmegaIngestReceipt`/`OmegaNodeReceipt`/Terminal-Session-Typen (laut AGENTS.md im Produkt zu halten). |
| REQ-020 | SHOULD | Das Paket bleibt UI-Logik-getrennt und konsumierbar per Git-`ref` oder lokalem `path`. | Reine Logik-Klassen sind ohne Flutter-Widget-Kontext testbar; README dokumentiert Git-`ref`- und `pubspec_overrides`-`path`-Konsum. |

## Architektur (kurz)

```
Produkt (aethelBrowser / aethelTerminal)
  └─ implementiert OmegaReadPlanePort (HTTP-Transport)
        │
        ▼
aethel_product_shells
  ├─ port/     OmegaReadPlanePort            (Vertrag)
  ├─ models/   OmegaWorkspaceMeta, OmegaEvidenceRef, OmegaInquiryChain,
  │            OmegaFederationBundle, OmegaLibraryReceiptNode, …  (@immutable)
  ├─ logic/    OmegaInquiryLogic, OmegaLibraryGraph, AssistantOmegaEvidence,
  │            OmnibarOmegaEvidence, OmegaNavigableUrl,
  │            formatOmegaInspectorLines, clipboardJsonObject   (UI-frei)
  └─ widgets/  OmegaWorkspacePanelBody, OmegaEntityInspectorBody (Material)
```

Externe Abhängigkeiten: nur `flutter` (SDK) und `meta`. Read-Plane-Backend
("knowledge stack") läuft separat in `aethel-omega` und wird per Bootstrap-Hinweis
referenziert, wenn `isReachable()`/`reachable` falsch ist.

## Offene Fragen

- Keine Widget-Tests vorhanden (REQ-016/REQ-017 nur über Logik/Code-Review
  abgedeckt) — Golden-/Widget-Tests sind ein offener Ausbaupunkt.
- Modell-`fromJson`-Pfade (REQ-003/REQ-004/REQ-014) sind noch nicht direkt
  unit-getestet; Abdeckung erfolgt indirekt über Logik-Tests.
