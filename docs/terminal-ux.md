# Terminal UX layer

This repo adds a small shared layer: **tmux**, **Starship**, and **interactive-only** aliases (bat/rg/fd/eza) via `~/.config/dotfiles/shell-extras.sh`. Dotfiles are applied with **chezmoi** (`dot_*` → `$HOME`).

## What changed (by platform)

### macOS

- **Brewfile**: terminal CLIs aligned with `packages.txt` where applicable (`starship`, `tmux`, `bat`, `ripgrep`, `fd`, `eza`, `lnav`, `gh`, `zoxide`, `chezmoi`, `btop`, `uv`), plus cask `font-jetbrains-mono-nerd-font` (alongside existing fonts). No duplicate `yarn`/`node` brew by default—use **nvm** (see `dot_zshrc`) and `corepack enable` when a project needs Yarn.
- **Shell**: [`dot_zshrc`](../dot_zshrc) initializes Homebrew PATH, optional Oh My Zsh, then Starship and shared extras. Put secrets in `~/.zshrc.local` (gitignored pattern).
- **Bootstrap**: [`macos/install.sh`](../macos/install.sh) runs `brew bundle` and optionally `rcup` when rcm is present; **chezmoi** is the canonical dotfile path—run `chezmoi apply` with this repo as your source (see [README](../README.md)).

### Arch Linux (typical laptop)

- **packages.txt**: adds `bat`, `ripgrep`, `fd`, `eza`, `lnav` (used by [`arch/bootstrap.sh`](../arch/bootstrap.sh) with `pacman`).
- Same chezmoi-managed configs as other platforms.

### Linux Mint / Debian-family

- **APT**: see [`linux/mint-apt-cli.txt`](../linux/mint-apt-cli.txt) for suggested package names and `batcat` / `fdfind` notes.
- **Shell**: If the interactive shell is **bash**, use chezmoi-applied `~/.bashrc` ([`dot_bashrc`](../dot_bashrc)). If **zsh**, use [`dot_zshrc`](../dot_zshrc). Both source the same `shell-extras.sh` only in interactive mode.
- If you already rely on a stock Mint/Ubuntu `~/.bashrc` (e.g. `command-not-found`), merge the blocks from `dot_bashrc` into yours or use `chezmoi merge` instead of overwriting blindly.

### Steam Deck / SteamOS

- **Do not** run [`arch/bootstrap.sh`](../arch/bootstrap.sh) blindly: SteamOS is not a generic Arch laptop; root may be immutable and updates are SteamOS-managed.
- **Safe**: Apply **user-level** configs only (`chezmoi apply` from your dotfiles source, or copy `dot_*` equivalents into `~/.config` and home).
- **Packages**: Prefer **distrobox**, **Flatpak**, or Deck-specific docs for installing extra CLI tools; avoid assumptions about `sudo pacman -Syu` on the host.

## Nerd Font (glyphs)

- Recommended: **JetBrains Mono Nerd Font** (installed on macOS via Brewfile cask when you `brew bundle`).
- **iTerm2**: Settings → Profiles → Text → Font → select a Nerd Font.
- Do not rely on this repo to set GUI plist defaults for fonts unless you add them yourself.

## Git config (`dot_gitconfig.tmpl`)

- **Global excludes**: `core.excludesfile` points to `~/.config/git/ignore` ([`dot_config/git/ignore`](../dot_config/git/ignore)), deployed by chezmoi—portable across machines.
- **Credential helper**: **macOS** uses `osxkeychain`; **Linux** uses `cache` by default. Override with `git config --global credential.helper store` or `libsecret` if you prefer.
- **Editor**: **macOS** uses `code --wait`; **Linux** defaults to `vim`. Override with `git config --global core.editor …` or a local `~/.gitconfig` include.

## Verify

1. **Chezmoi**: `chezmoi apply --dry-run` then `chezmoi apply`.
2. **Starship**: Open a new terminal; prompt shows directory, git, duration (after slow commands), hostname on SSH.
3. **Non-interactive**: `zsh -c 'alias cat'` should not define `cat` from extras (extras file returns early when `$-` has no `i`).
4. **tmux**: `tmux` → `Ctrl-b` then `|` / `-` for splits, `r` reloads config.
5. **macOS**: `brew bundle check` after editing Brewfile.

## Manual steps that may remain

- Install chezmoi and point it at this repo (or merge files manually).
- On Mint, install `starship`/`eza` if not in default repos (upstream or PPA).
- On Steam Deck, choose how you install CLIs (distrobox vs host) per Valve’s current guidance.
