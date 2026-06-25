# aethel_product_shells

Shared Ω workspace UI and read-plane models for **aethelBrowser** and **aethelTerminal**.

**GitHub:** https://github.com/AETHEL-Omega/aethel_product_shells

## Clone

```bash
cd ~/workspace
git clone https://github.com/AETHEL-Omega/aethel_product_shells.git
```

Sibling layout with browser/terminal (`../aethel_product_shells`) matches `AETHEL-Omega.code-workspace`.

## Contents

- `OmegaReadPlanePort` — shared HTTP read/propose surface
- Read models (`OmegaEvidenceRef`, `OmegaInquiryChain`, …)
- `OmegaWorkspacePanelBody` / `OmegaEntityInspectorBody` — Material widgets

## Consumers

Published dependency (CI + clean clones):

```yaml
dependencies:
  aethel_product_shells:
    git:
      url: https://github.com/AETHEL-Omega/aethel_product_shells.git
      ref: v0.1.0
```

Local package development: copy `pubspec_overrides.yaml.example` to `pubspec_overrides.yaml` in browser/terminal and use `path: ../aethel_product_shells`.

See `aethel-omega/docs/dev/CURRENT_SLICE.md` for active slice status.
