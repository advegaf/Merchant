# CLAUDE.md
Purpose: Persistent instructions for Claude Code when working on the “Merchant” iOS app. Priorities: correctness → performance → accessibility → aesthetics.

## Mission (TL;DR)
Suggest the best registered card at a venue and track rewards (estimated via Plaid; live via issuer OAuth when available). UI = Copilot/Robinhood-inspired, clean and fast, with a future-ready Liquid Glass aesthetic (feature-flagged). No sensitive card numbers stored.

## Platform Target
- iOS **26+ only**. Use modern SwiftUI APIs; do not add shims for older iOS. If an API is iOS 26-only, prefer it rather than workarounds.

## Non‑Negotiables
- PCI/Privacy: never store PAN/CVV/expiry or card photos. Keep issuer, network, last4, nickname, rule metadata only. Tokens in Keychain. Clear export/delete flows.
- Data sources: Plaid (transactions/MCC/liabilities) ⇒ compute **estimated** rewards; Issuer OAuth (partner APIs) ⇒ **live** points behind `IssuerSync`. No scraping.
- Location discipline: default “While Using”, minimal geofences, strict per-venue rate limits; graceful manual mode if disabled.
- Views are pure SwiftUI. MVVM with testable `final` ViewModels. No business logic in Views.
- Output style: plain text by default, compilable Swift; edits as unified diffs; keep changes minimal and focused.

## Visual System (SwiftUI-first, pristine UI)
- Design language: Copilot/Robinhood vibe—calm surfaces, strong hierarchy, high contrast in data tiles, subtle depth. Liquid Glass look is provided by **SwiftUI Materials + blur + translucency**, with careful contrast and motion reduction support.
- Theme tokens (Swift-only, no external libs):
  - `ThemeColor`, `ThemeSpacing`, `ThemeRadius`, `ThemeShadow`, `ThemeGradient` as lightweight structs with static tokens. Dark mode first-class.
  - Typography via SwiftUI text styles; honor Dynamic Type. Avoid fixed sizes where possible.
- Components (all SwiftUI, no UIKit bridging unless absolutely necessary):
  - `GlassCard`: frosted container using `.background(.ultraThinMaterial)` layered with a gradient mask and subtle inner glow. Falls back to `.regularMaterial` in high-contrast.
  - `CardStackView`: Wallet-style stacked cards with physicsy drag, focus/selection states, and 60fps scrolling.
  - `InsightTile`: compact metric tile (points earned this week, caps remaining) with SF Symbols, number formatting, and haptics on tap.
  - `BestCardPill`: “Best: <Card> (X% <Category>)” pill with small reason chevron → detail.
  - `NowBanner`: in-session banner (geofence active) with Live Activity handoff.
  - `RuleBadge`, `CapGauge`, `ReasonExplainer`: microcomponents for clarity.
- Motion & haptics:
  - Prefer `spring(response:dampingFraction:blendDuration:)` and `transaction`-scoped animations. Respect Reduce Motion.
  - Core Haptics wrapped in a tiny service: light taps for selects, medium for confirmations.
- Charts & maps:
  - Swift Charts for trends and category breakdowns (no third-party charts). Keep series count low, tooltips minimal.
  - MapKit SwiftUI `Map` with custom annotation chips for nearby venues.
- Liquid Glass (post-core styling):
  - Theme flag `LiquidGlass` controls frosted/translucent variants, parallax depth, and soft highlights.
  - Maintain readability under bright light; test contrast and legibility on photos/wallpapers.

## Targets & Stack
- Swift **6.x**+, SwiftUI, MVVM, async/await.
- Storage: SwiftData (local-first). Optional CloudKit behind `CloudSync`.
- Feature flags (owned in `App/FeatureFlags.swift`): `LiquidGlass=OFF` (until core validated), `CloudSync=OFF`, `PlaidSync=ON post Phase 6`, `IssuerSync=OFF`.
- No third-party UI frameworks. First-party only: SwiftUI, Swift Charts, MapKit, ActivityKit, TipKit, SF Symbols, Core Haptics.

## Repo Layout (authoritative)
App/ | Models/ | RulesEngine/ | Location/ | Notifications/ | Connectors/(Plaid|Issuer)/ | UI/(Home|Cards|Nearby|Rewards|Settings)/ | Theme/ | Tests/ | Fixtures/
- Every file starts with a top-of-file contract header: `// Rules:` (purpose, inputs, outputs, constraints).
- Use TODO tags like `// TODO(phase:X): ...` to align with milestones.

## Rules Engine Contract
Pure Swift module.
```
evaluate(input: DecisionInput) -> Decision {
  cardId: UUID,
  reason: String,          // human-readable “why this card”
  confidence: Double,      // 0.0–1.0
  breakdown: [String: Double] // contributions (category, promo, cap)
}
```
Inputs: MCC/venueType, time, caps remaining, promos/rotating windows. Deterministic + explainable. No IO/network.

## UI Direction (function > flash)
- Home/Insights: weekly earned $, top categories, cap trackers, suggestion tiles (“At this place: Use <Card> (X% <Category>)”). Snapshot-load fast.
- Cards: Wallet-style stacked cards; top card = current suggestion; show multipliers, caps remaining, rotating windows, network badge.
- Nearby: Map + ranked list + “Best: <Card> (X% <Category>)” pill; “Why?” explainer routes to Card detail.
- Rewards: Ledger (earned/redeemed), filters, caps, CSV export; badges: `estimated` vs `live`.
- Settings: privacy/location modes, geofence density, notifications tuning, connectors (Plaid/Issuer), rule import/export, data export/delete.
- Liquid Glass theme comes **after** core validations; gate via `LiquidGlass` (but design tokens/components are built from day one).

## Milestones (halt if validation fails)
0 Shell → 1 Models → 2 Rules → 3 Location → 4 Suggestions/Notifications → 5 Rewards → 6 PlaidSync → 7 IssuerSync → 8 Perf/A11y → 9 LiquidGlass.

## Validation Gates (must pass)
- RulesEngine golden vectors (Grocery/Gas/Dining/Rotating) match Decision + reason.
- Geofence enter ⇒ exactly one suggestion in 3–8s ⇒ tap routes to card detail with “why.”
- Rewards math reconciles within ±1% on fixtures; badges behave.
- Connectors: Plaid sandbox fixtures ingest; IssuerSync mock returns points when available; fall back gracefully.
- Perf: cold start <1.2s; 60fps Cards stack on modern devices; minimal background wakeups.

## Working Agreements (Claude Code behavior)
- New files: full compilable Swift with `// Rules:` header + minimal previews.
- Edits: unified diffs with the smallest viable change set; one-line rationale for non-obvious choices.
- Ambiguity: pick sane defaults; add `Assumption: …` (one line).
- Never invent non-standard iOS APIs; if needed, stub and isolate behind a protocol.
- After each functional chunk, print a tiny “Validation checklist” and mark PASS/FAIL.
