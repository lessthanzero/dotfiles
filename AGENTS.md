# Dotfiles — Agent Operating Protocol

This file governs how AI coding assistants (Antigravity, Cursor, Codex, Claude Code) interact with this repository.

---

## 1. Operating Boundaries & Architecture

- **Project Role**: System configuration, shell environments, agent skills, and peer review tooling managed via `chezmoi`.
- **Workbench Profile**: `systems/dotfiles`.
- **Key Directories**:
  - `dot_config/`: Configurations for Kitty, Hammerspoon, etc.
  - `scripts/agent/`:
    - `consilium.sh`: Multi-model peer review harness (local Qwen + cloud models).
    - `flow-analyzer.sh`: Client UX review CLI wrapper.
    - `sync-forgejo.sh`: Mirroring to Fedora PC homelab Forgejo instance.
  - `skills/`: Reusable agent skills symlinked into `~/.gemini/config/skills/`.
  - `dot_zshrc`: Shell aliases and environment paths.

---

## 2. Chezmoi & Synchronization Protocol

- Root files without `dot_` prefix are chezmoi metadata/docs and are ignored by chezmoi sync (configured in `.chezmoiignore`).
- Dotfiles to be deployed to `$HOME` must follow the `dot_` naming convention (e.g. `dot_zshrc` -> `~/.zshrc`).
- Verify changes with `chezmoi diff` before applying.
