# aethel_product_shells

Shared Ω workspace UI and read-plane models for **aethelBrowser** and **aethelTerminal**.

**GitHub:** https://github.com/AETHEL-Omega/aethel_product_shells

## Clone

```bash
cd ~/workspace
git clone https://github.com/AETHEL-Omega/aethel_product_shells.git
```

Sibling layout with browser/terminal (`../aethel_product_shells`) matches `AETHEL-Omega.code-workspace`.

## Contents (v0.1.3)

| Area | Symbols |
|------|---------|
| Port | `OmegaReadPlanePort` |
| Models | `OmegaEvidenceRef`, `OmegaInquiryChain`, `OmegaLibraryReceiptNode`, `OmegaOmnibarEvidenceSuggestion`, … |
| Widgets | `OmegaWorkspacePanelBody`, `OmegaEntityInspectorBody` |
| Logic | `OmegaInquiryLogic`, `OmegaLibraryGraph`, `AssistantOmegaEvidence`, `OmnibarOmegaEvidence`, `OmegaNavigableUrl`, clipboard + inspector format |

Browser-only ingest types (`OmegaIngestReceipt`, `OmegaNodeReceipt`) stay in `aethelBrowser`.

## Consumers

Published dependency (CI + clean clones):

```yaml
dependencies:
  aethel_product_shells:
    git:
      url: https://github.com/AETHEL-Omega/aethel_product_shells.git
      ref: v0.1.3
```

Local package development: copy `pubspec_overrides.yaml.example` to `pubspec_overrides.yaml` in browser/terminal and use `path: ../aethel_product_shells`.

## Tags

| Tag | Slice |
|-----|-------|
| v0.1.0 | P55 workspace + inspector |
| v0.1.1 | P57 library graph |
| v0.1.2 | P58 assistant evidence |
| v0.1.3 | P59 omnibar evidence |
| v0.1.4 | P60 knowledge stack offline hint |

See `aethel-omega/docs/dev/CURRENT_SLICE.md` for active slice status.
