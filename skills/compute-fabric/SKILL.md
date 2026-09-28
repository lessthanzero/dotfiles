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
node limits need checking. The current distributed queue accepts only `llm`
prompts and `text_stats` over explicit UTF-8 text, up to 256 KiB. It does not
execute repository agents, shell commands, browser work, vision, PDFs, or
arbitrary files. Explain the limit when the requested work needs those tools.

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

## Submit supported jobs

Use `local-harness submit --type llm --prompt '…'` for a short prompt, or
`--type text_stats --input-file FILE` for short text. Select `--role coding` or
`general`, `--priority interactive|background|night|opportunistic`, and repeat
`--allow-node NODE` for eligible nodes. Include `macbook-mobile` when it is
online, enabled, not busy or degraded, and supports the job; pass both
`--allow-node macbook-mobile` and `--share-with-mobile` to authorize that route.
The user's standing preference permits supported, non-secret text inputs to be
shared with this node under those conditions. If it is unavailable, omit it.
An explicit request to use all nodes means **one job eligible for all ready
supported workers**, not parallel or duplicate execution; the first eligible
worker leases it. Explain the selected eligible nodes, since the actual worker
is determined only when a lease is taken.

Do not put passwords, tokens, API keys, or apparent secrets in a job payload.
Do not enable, disable, remove, or install workers as a side effect of routing.
Report the selected route and job ID, then use `local-harness result JOB_ID` to
return a completed result when available. For queue visibility, use
`local-harness jobs` or `local-harness report --hours 8`.
