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

```yaml
dependencies:
  aethel_product_shells:
    path: ../aethel_product_shells
```

See `aethel-omega/docs/dev/CURRENT_SLICE.md` for active slice status.
