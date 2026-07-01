---
name: memorise
description: >-
  Persists chat context, facts, decisions, and system configurations to the iCloud Obsidian vault,
  runs the mirror script to sync to vault-mirror local repository, and commits/pushes to GitHub.
  Trigger when the user says "memorise", "memorise knowledge", or asks to document/persist knowledge to the vault.
---

# Memorise Skill

This skill allows Antigravity to persist conversation knowledge to the Obsidian vault, sync it to the local mirror repository, and push it to GitHub.

## Paths

| Role | Path |
| :--- | :--- |
| **Source Vault (iCloud)** | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault` |
| **Mirror Repo (Git)** | `~/Developer/vault-mirror` |
| **Mirror Script** | `/usr/local/bin/obsidian-to-mirror.sh` |
| **Remote Repository** | `https://github.com/lessthanzero/vault-mirror.git` |

---

## Workflow

1. **Identify the Document & Content:**
   * Determine what configs, decisions, commands, or maintenance logs need to be documented.
   * Pick the appropriate subdirectory under the vault (e.g., `ops/` for infrastructure, tooling, and networks; `areas/` for life/domain context; `notes/` for general reference).
   * Check for existing documents to update or append to, rather than creating duplicates.
   * Add a `Last updated: YYYY-MM-DD` line under the main header.

2. **Write/Update the iCloud Vault:**
   * Write the file directly to the iCloud path: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault/path/to/file.md`.
   * Keep formatting matching neighboring files, using standard Obsidian wikilinks `[[other-note]]` for cross-references.

3. **Check for Unrelated Changes:**
   * Before running the mirror, check if `~/Developer/vault-mirror` has uncommitted workspace drift (like `.obsidian` metadata changes).
   * Stage and commit any unrelated changes first with a clean message (e.g. `Sync incidental vault-mirror changes before memorise mirror.`) to keep commits clean.

4. **Sync the Vault to the Mirror:**
   * Execute the mirroring script to copy changes: `/usr/local/bin/obsidian-to-mirror.sh`.

5. **Stage, Commit, and Push:**
   * Stage only the relevant files in the `vault-mirror` repository.
   * Commit with a descriptive message explaining *why* the context was memorized.
   * Push changes to GitHub: `git -C ~/Developer/vault-mirror push -u origin HEAD`.
