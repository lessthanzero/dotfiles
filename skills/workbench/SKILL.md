---
name: workbench
description: Apply Workbench design taste, typography, UX principles, technology profiles, and architecture rules to projects. Use when the user says "use workbench", "utilise workbench", "apply workbench", or asks to align a project with Workbench standards.
---

# Workbench: Personal Reusable Development & Design System

Workbench is a personal knowledge and tooling layer for building digital products efficiently with AI agents. It captures proven design taste, typography pairings, UX heuristics, technology defaults, and architecture decisions.

**Canonical Knowledge Base**: `~/Developer/workbench`
**Core CLI Tool**: `~/Developer/workbench/tools/workbench.py`

---

## 1. Core Operating Principles

1. **Context Efficiency**: Never inject the entire Workbench knowledge base into a project context. Always extract a targeted slice using `workbench.py slice` or `workbench.py export-context`.
2. **Local-First**: Prefer local files, local tools, and local models (Fedora PC worker Ollama on `pc:11434` / `local-harness`).
3. **Opinionated, but Replaceable**: Defaults are reasons, not immutable laws.
4. **Socratic Rationale Gate**: Never follow unreasoned critique blindly. If the user provides a preference or critique without explaining *why*, **ask for the reasoning** before codifying it.
5. **Separation of Trust**: Project-level decisions live in `<project>/Docs/DESIGN_DECISIONS.md`. System-level principles in `~/Developer/workbench/` require explicit user promotion and privacy redaction.

---

## 2. Agent Execution Workflow

When instructed to *"use workbench"*, *"utilise workbench"*, or *"apply workbench"* on a target repository:

### Step 1: Identify Project Profile & Domain
Inspect the target project's stack and domain:
* `static-web`: Content sites, landing pages (Astro, Tailwind, `@katin/ui`).
* `web-app-mvp`: Fast single-user web tools (Next.js, SQLite, Drizzle).
* `web-saas`: Multi-user SaaS platforms (Next.js, PostgreSQL, Drizzle).
* `apple-native`: iOS/macOS apps with telemetry (Swift, SwiftUI, HealthKit, WidgetKit).
* `ai-data-service`: Python data processing, document triage, background workers.

### Step 2: Query Targeted Workbench Slices
Run the zero-dependency CLI to extract only relevant rules within a strict character budget:

```bash
# Query principles and typography for a mobile app
python3 ~/Developer/workbench/tools/workbench.py slice --tags "mobile,typography" --max-chars 4000

# Query specific design rules
python3 ~/Developer/workbench/tools/workbench.py slice --query "density" --max-chars 3000

# Export tailored AGENTS.md / DESIGN.md for a profile
python3 ~/Developer/workbench/tools/workbench.py export-context --profile apple-native
```

### Step 3: Audit & Align Project Against Rules
Check the target project against Workbench invariants:
* **Typography Over Containers**: Are blocks needlessly wrapped in cards? Use line-height, weight contrast, and section spacing first.
* **Warm Canvas & Hairline Borders**: Is the canvas stark white (`#FFFFFF`)? Replace with warm linen/paper (`#FAF8F5`, `#fefdf8`, `#e8e6e1`) and 1px hairline borders (`rgba(0,0,0,0.08)`).
* **Tabular Monospace Numerals**: Do live timers, counters, or financial amounts jitter? Attach `.monospacedDigit()` in SwiftUI or `font-variant-numeric: tabular-nums` in CSS.
* **Quiet Action Ladder**: Exactly 1 prominent primary action per view; secondary actions muted.

---

## 3. Socratic Feedback Absorption (Self-Improvement)

When the user provides feedback, design critiques, or new preferences during development:

1. **Verify Rationale**:
   * If the user gave clear reasoning (e.g. *"Use rounded fonts because it's a parenting app and parents at 3am need gentle comfort"*):
     $\rightarrow$ Proceed immediately.
   * If the user gave **NO reasoning** (e.g. *"Change font to rounded"* or *"Make the border thick"*):
     $\rightarrow$ **HALT and ask**:
     > *"What is the primary rationale for this choice?"*
     *(Exception: In non-interactive batch runs, append `--pending-rationale` to log without blocking).*

2. **Ingest at Project Level**:
   ```bash
   python3 ~/Developer/workbench/tools/workbench.py feedback add \
     --project <project-name> \
     --subject "<Descriptive Subject>" \
     --observation "<What was critiqued>" \
     --reasoning "<User's explained rationale>" \
     --scope project \
     --project-dir <path-to-project>
   ```

3. **Promote to System Level (Only when explicitly instructed)**:
   When the user says *"Promote this to Workbench system level"*:
   ```bash
   python3 ~/Developer/workbench/tools/workbench.py feedback promote <feedback-id>
   ```
   *(Verifies redaction of private emails, client secrets, and internal tokens before promoting).*

---

## 4. Compute-Fabric Pipeline Integration

To offload an automated code audit or design review to local nodes across the compute fabric:

1. **Package Evaluation Prompt**:
   ```bash
   python3 ~/Developer/workbench/tools/workbench.py fabric-eval \
     --project ~/Developer/marksParent/littleMark \
     --profile apple-native \
     --max-chars 16384
   ```
   *Guarantees prompt size $\le 16$ KiB (~4k tokens) to prevent VRAM spills on local Ollama nodes.*

2. **Submit to Fabric**:
   ```bash
   python3 ~/Developer/workbench/tools/workbench.py fabric-eval \
     --project ~/Developer/marksParent/littleMark \
     --profile apple-native \
     --submit \
     --priority interactive \
     --allow-node fedora \
     --allow-node macbook-mobile
   ```

3. **Check Result**:
   ```bash
   ~/Developer/local-models/.venv/bin/local-harness result <JOB_ID>
   ```
