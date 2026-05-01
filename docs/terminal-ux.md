# Terminal UX layer

Shared pieces: **tmux**, **interactive-only** aliases (bat/rg/fd/eza) via [`dot_config/dotfiles/shell-extras.sh`](../dot_config/dotfiles/shell-extras.sh), **zsh + Oh My Zsh + Powerlevel10k** ([`dot_zshrc`](../dot_zshrc), [`dot_p10k.zsh`](../dot_p10k.zsh)), and **Starship** only for **bash** ([`dot_bashrc`](../dot_bashrc), [`dot_config/starship.toml`](../dot_config/starship.toml)). Dotfiles apply with **chezmoi** (`dot_*` → `$HOME`).

## Capability matrix (Arch vs Mint vs installers)

| Capability | Arch ([`packages.txt`](../packages.txt)) | Mint (`apt`, [`mint-apt-cli.txt`](../linux/mint-apt-cli.txt)) | Otherwise |
|------------|--------------------------------------------|---------------------------------------------------------------|-----------|
| Shell | `zsh` | `zsh` | — |
| Prompt (zsh) | Powerlevel10k (git; [`arch/bootstrap.sh`](../arch/bootstrap.sh)) | same clone step | — |
| Prompt (bash) | optional Starship | optional Starship | [`linux/bootstrap-cli.sh`](../linux/bootstrap-cli.sh) |
| Git / GitHub | `git`, `github-cli` | `git`, `gh` | — |
| Modern CLI | `bat`, `ripgrep`, `fd`, `eza`, `lnav` | `bat`, `ripgrep`, `fd-find`, `eza`, `lnav` | `bat`→`batcat`, `fd`→`fdfind`: [`shell-extras.sh`](../dot_config/dotfiles/shell-extras.sh) |
| Navigation | `zoxide` | `zoxide` | — |
| Monitor | `btop` | `btop` | — |
| Multiplexer | `tmux` | `tmux` | — |
| Dotfile manager | `chezmoi` | — | official install ([bootstrap-cli](../linux/bootstrap-cli.sh)) |
| Python tooling | `uv` | — | Astral install script |
| Obsidian | `obsidian` (pacman) | Flatpak ([`run_once_install_flatpaks.sh`](../linux/run_once_install_flatpaks.sh)) | intentional difference |

**Node**: Prefer **nvm** ([`dot_zshrc`](../dot_zshrc)). Arch lists system Node in `packages.txt`; on Mint/Debian avoid apt `nodejs` unless you explicitly want it alongside nvm.

## What changed (by platform)

### macOS

- **Brewfile**: CLIs aligned with `packages.txt` where applicable (`tmux`, `bat`, `ripgrep`, `fd`, `eza`, `lnav`, `gh`, `zoxide`, `chezmoi`, `btop`, `uv`), plus cask `font-jetbrains-mono-nerd-font`. No duplicate `yarn`/`node` brew by default—use **nvm** and `corepack enable` when a project needs Yarn.
- **Shell**: [`dot_zshrc`](../dot_zshrc) initializes Homebrew PATH, Oh My Zsh (when present), **Powerlevel10k** (Tokyo Night–tuned [`dot_p10k.zsh`](../dot_p10k.zsh)), then shared extras. Put secrets in `~/.zshrc.local` (gitignored pattern).
- **Bootstrap**: [`macos/install.sh`](../macos/install.sh) runs `brew bundle` and optionally `rcup` when rcm is present; **chezmoi** is the canonical dotfile path—run `chezmoi apply` with this repo as your source (see [README](../README.md)).

### Arch Linux (typical laptop)

- **packages.txt**: `bat`, `ripgrep`, `fd`, `eza`, `lnav`, etc. via [`arch/bootstrap.sh`](../arch/bootstrap.sh) (`pacman`). **Starship** is not installed here (zsh uses p10k).
- [`arch/bootstrap.sh`](../arch/bootstrap.sh) clones Powerlevel10k into `~/.oh-my-zsh/custom/themes` and runs `chezmoi apply`.

### Linux Mint / Debian-family

- **Bootstrap**: [`linux/bootstrap-cli.sh`](../linux/bootstrap-cli.sh) runs `apt-get install` for the APT column above, then installs **chezmoi**, **uv**, and **Starship** (bash) if missing.
- **APT list**: [`linux/mint-apt-cli.txt`](../linux/mint-apt-cli.txt) — same packages as copy-paste reference.
- **Shell**: **bash** → [`dot_bashrc`](../dot_bashrc) (Starship Tokyo Night preset). **zsh** → [`dot_zshrc`](../dot_zshrc) + **Powerlevel10k**. Both source `shell-extras.sh` only in interactive mode.
- If you rely on a stock Mint/Ubuntu `~/.bashrc` (e.g. `command-not-found`), merge the blocks from `dot_bashrc` or use `chezmoi merge`.

### Steam Deck / SteamOS

- **Do not** run [`arch/bootstrap.sh`](../arch/bootstrap.sh) blindly: SteamOS is not a generic Arch laptop; root may be immutable and updates are SteamOS-managed.
- **Safe**: **User-level** configs only (`chezmoi apply` from your dotfiles source, or copy `dot_*` equivalents into `~/.config` and home).
- **Packages**: Prefer **distrobox**, **Flatpak**, or Deck-specific docs for CLIs; avoid `sudo pacman -Syu` on the host without checking Valve’s current guidance.

## Fonts (JetBrains Mono + Nerd)

- **macOS**: `font-jetbrains-mono-nerd-font` in [`Brewfile`](../Brewfile); **iTerm2**: Settings → Profiles → Text → select the Nerd Font.
- **Linux Mint / Debian**: `sudo apt install fonts-jetbrains-mono` for the base family; for **Nerd** glyphs (Powerlevel10k / Starship icons), install a [Nerd Font](https://www.nerdfonts.com/font-downloads) build of JetBrains Mono and select it in your terminal (GNOME Terminal, Tilix, Kitty, etc.).
- This repo does not set GUI font keys for every desktop; pick the font in the terminal profile once.

## Git config (`dot_gitconfig.tmpl`)

- **Global excludes**: `core.excludesfile` → `~/.config/git/ignore` ([`dot_config/git/ignore`](../dot_config/git/ignore)).
- **Credential helper**: **macOS** `osxkeychain`; **Linux** `cache` by default. Override with `git config --global credential.helper store` or `libsecret` if you prefer.
- **Editor**: **macOS** `code --wait`; **Linux** `vim`. Override with `git config --global core.editor …` or a local include.

## Verify

1. **Chezmoi**: `chezmoi apply --dry-run` then `chezmoi apply`.
2. **zsh / Powerlevel10k**: New zsh session shows rainbow/Tokyo Night–style two-line prompt; `p10k configure` to regenerate `~/.p10k.zsh` locally (optional).
3. **bash / Starship**: `bash -il` (or login shell) shows Tokyo Night ribbon prompt from [`starship.toml`](../dot_config/starship.toml).
4. **Non-interactive**: `zsh -c 'alias cat'` should not define `cat` from extras (extras returns early when `$-` has no `i`).
5. **tmux**: `tmux` → `Ctrl-b` then `|` / `-` for splits, `r` reloads config.
6. **macOS**: `brew bundle check` after editing Brewfile.

## Manual steps that may remain

- Install [Oh My Zsh](https://ohmyz.sh/) and clone Powerlevel10k (see [README](../README.md)) if `arch/bootstrap.sh` / Mint bootstrap has not already done so.
- On Steam Deck, choose distrobox vs host for CLIs per Valve’s current guidance.
