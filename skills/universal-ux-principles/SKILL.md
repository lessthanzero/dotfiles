---
name: universal-ux-principles
description: Universal principles of UX, interaction heuristics, cognitive ergonomics, and usability guidelines derived from Irene Pereyra (Anton & Irene) and timeless product design practice. Use when designing or auditing user flows, mobile interfaces, form ergonomics, error handling, or cognitive accessibility.
---

# Universal UX Principles & Cognitive Ergonomics

Distilled operational guidelines, interaction heuristics, and usability criteria based on Irene Pereyra's *Universal Principles of UX* (Rockport, 2023) and modern interface engineering standards.

---

## 1. Core Usability Heuristics

1. **Aesthetic-Usability Effect**:
   * Users perceive aesthetically balanced, typographic, and harmonious interfaces as more usable.
   * High visual polish increases user patience with minor operational delays, but cannot rescue broken flows or missing data.
2. **Work on UX and UI Simultaneously**:
   * Never isolate wireframing from visual and typographic styling.
   * Font scale, contrast, line-height, and padding directly determine whether an information structure is scannable or broken.
3. **Tesler's Law (Conservation of System Complexity)**:
   * Every process has an inherent complexity that cannot be removed.
   * The software must absorb that complexity (smart parsing, sensible defaults, automation, background synchronization) rather than pushing it onto the user.
4. **Hick's Law (Decision Latency)**:
   * Time to decide increases logarithmically with the number and complexity of choices.
   * Limit primary choices per screen to 3–5 items. Use progressive disclosure or segmented pills for secondary branches.
5. **Postel's Law (Robustness Principle)**:
   * Be conservative in what you render/emit; be liberal and forgiving in what you accept from the user.
   * Strip spaces, brackets, and international prefixes from phone numbers; parse messy date strings (`28 Sep`, `28/09`, `yesterday`) without kicking errors.

---

## 2. Mobile Ergonomics & Physical Constraints

1. **The Thumb Zone**:
   * Primary interactive targets and switchers belong in the bottom 40% of the screen.
   * Destructive, secondary, or infrequent navigational anchors belong in the top corners.
2. **Clumsy Handling & Touch Geometry**:
   * Minimum tap target size: **44 × 44 pt** (Apple Human Interface Guidelines) or **48 × 48 dp** (Material).
   * Generous touch hit-slop: expand the invisible touch container beyond the icon glyph bounds.
   * Never place two critical tap targets with opposing outcomes (e.g. "Save" vs "Discard") adjacent to each other without at least 16px separation.
3. **Environmental Context**:
   * Design for 3am dark rooms (pure OLED `#000000` blacks, warm amber inks, zero glare) and direct midday sunlight (high contrast, bold weight distinctions, no low-contrast gray-on-white body copy).
   * Design for one-handed operation while holding a baby, carrying luggage, or walking.

---

## 3. Deliberate Friction vs. Flow Velocity

1. **Friction is a Safety Mechanism**:
   * Do not make everything a single tap.
   * Irreversible, destructive, or high-consequence actions require intentional friction:
     * Hold-to-confirm triggers (1.5s press with tactile progress arc and haptic detent).
     * 10-second undo toast window before background execution commits.
2. **Zero Friction for Frequent Telemetry**:
   * Routine tracking (logging a diaper change, recording water intake, ticking off a task) must require $\le 2$ taps and under 3 seconds.
   * Pre-fill timestamp to `currentTime` automatically with optional one-tap adjustment.

---

## 4. Typography as Interface Architecture

1. **90% of UX is Typography**:
   * Do not rely on decorative boxes, cards, or outlines to separate information.
   * Establish visual rhythm via:
     $$\text{Line-Height} < \text{Paragraph Spacing} < \text{Subheading Margin} < \text{Section Gap}$$
2. **Tabular Monospace Numerals (`tnum`)**:
   * Every live counter, timer, clock, financial amount, and percentage metric must use tabular figures (`font-variant-numeric: tabular-nums` in web or `.monospacedDigit()` in SwiftUI).
   * Variable-width numerals jitter horizontally when ticking, destroying visual calm.
3. **Domain-Calibrated Font Character**:
   * *Parenting / Maternal*: SF Pro Rounded or warm humanist type for titles and labels provides gentleness, empathy, and emotional comfort without sacrificing clarity.
   * *Financial / Legal*: Neutral geometric grotesque or crisp transitional serifs convey rigor, precision, and auditability.
   * *Technical / Telemetry*: Monospace and dense sans-serif for rapid diagnostic scanning.

---

## 5. Error Management & Broken States

1. **Inline Contextual Errors**:
   * Display validation errors immediately adjacent to the offending input, not in an abstract banner at the top of the viewport.
   * State specifically how to fix the error (e.g. *"Enter an amount between £10 and £5,000"* rather than *"Invalid value"*).
2. **Never Wipe User Data**:
   * If a form submission fails (network disconnect, server error), preserve all user-entered inputs in state or local storage.
3. **Actionable Empty & Broken States**:
   * An empty list must never show a blank void. Provide a friendly illustration or icon, explain why it is empty, and provide a single primary CTA to create the first record.
   * 404 pages and network offline screens must offer a clear path back to safe ground.

---

## 6. Review Checklist for UX Audits

- [ ] Can the user complete the primary flow in under 3 taps/clicks from launch?
- [ ] Are tap targets at least 44×44pt with comfortable spacing?
- [ ] Are primary actions visually distinct from secondary/ghost actions?
- [ ] Do timers and counters use monospace digits to prevent layout jitter?
- [ ] Is destructive state change guarded by hold-to-confirm or an undo window?
- [ ] Does the interface function gracefully in poor light (dark mode) or outdoor glare?
- [ ] Are inputs forgiving of non-standard formats (spaces, dashes, casing)?
- [ ] Is wording explicit and action-oriented ("Log Diaper", "Download PDF") rather than vague ("Submit", "OK")?
