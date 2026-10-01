---
name: compute-fabric
description: >-
  Inspect and route supported work through the local compute fabric. Use for
  requests such as "what can I do with the nodes?", "which node should handle
  this?", "use local compute", "use the compute fabric", "use all available
  nodes", or "offload this to Fedora". Generic mentions of compute or nodes
  alone do not call for this skill.
---

# Compute fabric

Use the `local-harness` CLI in `~/Developer/local-models` for node status,
routing, and supported jobs. Read `docs/fabric.md` there if command behavior or
node limits need checking.

There are two lanes:

1. **Typed queue** — `local-harness submit` for bounded jobs: `llm`,
   `text_stats`, `pdf_extract`, and `vision_caption`. Inputs are capped at
   256 KiB (binary jobs are base64-wrapped file bytes). It does not execute
   repository agents, arbitrary shell, or browser work.
2. **Node workflows outside the queue** — when the user needs richer work on a
   machine (health scripts, `local-harness local`, an existing repo task already
   run there), use the explicit SSH/agent path below. Do not invent a free-form
   remote shell job type.

Explain the limit when the requested work needs tools the queue does not offer.

## Check before routing

Run `local-harness status` for the current machine and `local-harness jobs` for
the coordinator queue and node state. If the CLI is absent from PATH, use the
existing `~/Developer/local-models/.venv/bin/local-harness` on the primary Mac,
or `.venv-fabric/bin/local-harness` on Fedora and Kate's M3 Air. Do not install
or reconfigure anything to answer a routing request. If the coordinator cannot
be reached, report that and use only an explicitly requested local workflow.

- Fedora holds the durable queue and polls for background work. Prefer it for
  asynchronous general or coding prompts and night jobs.
- The M1 Pro is the primary interactive machine. Its queue worker runs on
  demand and may defer under load; for a prompt needed immediately, consider
  `local-harness local --role general '…'` or `--role coding` there.
- Kate's M3 Air can run local coding and general prompts offline. Its shared
  worker is available only when enabled, on AC, idle, and above its resource
  floors. Include it in normal distributed routing when the coordinator reports
  it online and its advertised profile supports the job. Its next worker poll
  checks readiness again, so an online status is not a guarantee it will lease.
- The old Air has no enabled harness worker. The Pis and QNAP are not compute
  workers.

Respect the current mode, node availability, model/role support, and resource
gates. `mode offline` blocks coordinator calls; a mobile node can still use its
local models. Do not treat a registered node as ready merely because it appears
in the queue view.

## Diagnose access before routing

`local-harness status` describes the current process and host. Check its live
`profile.ollama.status`, `profile.job_types`, and model tags before treating an
empty top-level `models` list as proof that no weights are installed. A ready
worker with only `text_stats` (and `pdf_extract`) can process text statistics
or PDF text extraction but cannot run LLM or vision jobs.

When a local model call fails, distinguish these cases:

- **Unreachable / permission denied:** the process cannot reach the Ollama API.
  `Operation not permitted` can mean the execution sandbox blocked loopback or
  SSH even while the host service or remote node is up. Report the exact layer
  and stop retrying through alternate interfaces. Do not rebind Ollama to a
  network interface, change firewall rules, disable the sandbox, or tunnel
  around the restriction.
- **Connection refused:** the endpoint was reachable at the network layer but
  no process accepted the connection. This is a service-listener issue, not an
  empty model list.
- **Reachable with no models:** only a successful API response containing an
  empty model list establishes that state. Compare configured model tags with
  the live API tags; files under Ollama's model store are not proof that the
  daemon can load them.
- **Remote node:** `tailscale status` shows tailnet presence, not worker
  readiness. Use the harness's coordinator status for lease capability. If SSH
  returns `Operation not permitted`, classify the check as blocked by the
  current execution environment instead of calling the node offline.

If a user asks for local-first review and local inference is inaccessible,
report the blocked local route. Do not silently substitute cloud inference;
continue with source-based analysis and ask before routing text to a hosted peer
unless the current request already authorizes that fallback.

## Submit supported jobs

Use:

- `local-harness submit --type llm --prompt '…'` for a short prompt
- `--type text_stats --input-file FILE` for short UTF-8 text
- `--type pdf_extract --input-file FILE.pdf` for a small PDF (≤ ~190 KiB raw)
- `--type vision_caption --input-file IMAGE --prompt '…'` for a small image

Select `--role coding` or `general` (llm), `--priority
interactive|background|night|opportunistic`, and repeat `--allow-node NODE` for
eligible nodes. Include `macbook-mobile` when it is online, enabled, not busy or
degraded, and supports the job; pass both `--allow-node macbook-mobile` and
`--share-with-mobile` to authorize that route. The user's standing preference
permits supported, non-secret text inputs to be shared with this node under
those conditions. If it is unavailable, omit it. An explicit request to use all
nodes means **one job eligible for all ready supported workers**, not parallel
or duplicate execution; the first eligible worker leases it. Explain the
selected eligible nodes, since the actual worker is determined only when a
lease is taken.

Do not put passwords, tokens, API keys, or apparent secrets in a job payload.
Do not enable, disable, remove, or install workers as a side effect of routing.
Report the selected route and job ID, then use `local-harness result JOB_ID` to
return a completed result when available. For queue visibility, use
`local-harness jobs` or `local-harness report --hours 8`.

## Work beyond the typed queue

When the user needs more than prompts, text stats, PDF extract, or vision
caption on another node:

- Prefer **Fedora** (`ssh pc` or Tailscale host already used for harness) for
  durable background work, health scripts under `~/Developer/local-models`, and
  `local-harness local` / worker ops that already exist on that machine.
- Run only workflows the user asked for or that already exist as project
  scripts. Do not invent arbitrary remote shell automation or enable/disable
  workers unless requested.
- Keep secrets off the wire. Prefer content-free checks (status, health, model
  list) over shipping private documents.
- Browser jobs and distributed coding agents are **not** fabric job types yet.
  If those are required, say so and stay on the interactive machine or an
  explicitly requested remote agent session outside the queue.

## Deferred typed handlers

Not yet in the queue: browser jobs, distributed coding agents, automatic QNAP
archive. Do not claim those are available via `local-harness submit`.
