# Terminal UX layer

Shared pieces: **tmux**, **Kitty** (default terminal on Linux Mint/XFCE), **interactive-only** aliases (bat/rg/fd/eza) via [`dot_config/dotfiles/shell-extras.sh`](../dot_config/dotfiles/shell-extras.sh), **zsh + Oh My Zsh + Powerlevel10k** ([`dot_zshrc`](../dot_zshrc), [`dot_p10k.zsh`](../dot_p10k.zsh)), and **Starship** only for **bash** ([`dot_bashrc`](../dot_bashrc), [`dot_config/starship.toml`](../dot_config/starship.toml)). Dotfiles apply with **chezmoi** (`dot_*` → `$HOME`).

## Capability matrix (Arch vs Mint vs installers)

| Capability | Arch ([`packages.txt`](../packages.txt)) | Mint (`apt`, [`mint-apt-cli.txt`](../linux/mint-apt-cli.txt)) | Otherwise |
|------------|--------------------------------------------|---------------------------------------------------------------|-----------|
| Shell | `zsh` | `zsh` | — |
| Prompt (zsh) | Powerlevel10k (git; [`arch/bootstrap.sh`](../arch/bootstrap.sh)) | same clone step | — |
| Prompt (bash) | optional Starship | optional Starship | [`linux/bootstrap.sh`](../linux/bootstrap.sh) |
| Git / GitHub | `git`, `github-cli` | `git`, `gh` | — |
| Modern CLI | `bat`, `ripgrep`, `fd`, `eza`, `lnav` | `bat`, `ripgrep`, `fd-find`, `eza`, `lnav` | `bat`→`batcat`, `fd`→`fdfind`: [`shell-extras.sh`](../dot_config/dotfiles/shell-extras.sh) |
| Navigation | `zoxide` | `zoxide` | — |
| Monitor | `btop` | `btop` | — |
| Multiplexer | `tmux` | `tmux` | — |
| Terminal (Kitty) | `kitty` | `kitty` | — |
| Dotfile manager | `chezmoi` | — | official install ([bootstrap.sh](../linux/bootstrap.sh)) |
| Python tooling | `uv` | — | Astral install script |
| Obsidian | `obsidian` (pacman) | Flatpak ([`run_once_install_flatpaks.sh`](../linux/run_once_install_flatpaks.sh)) | intentional difference |

**Node**: Prefer **nvm** ([`dot_zshrc`](../dot_zshrc)). Arch lists system Node in `packages.txt`; on Mint/Debian avoid apt `nodejs` unless you explicitly want it alongside nvm.

## What changed (by platform)

### macOS

- **Brewfile**: CLIs aligned with `packages.txt` where applicable (`tmux`, `bat`, `ripgrep`, `fd`, `eza`, `lnav`, `gh`, `zoxide`, `chezmoi`, `btop`, `uv`), plus cask `font-jetbrains-mono-nerd-font`. No duplicate `yarn`/`node` brew by default—use **nvm** and `corepack enable` when a project needs Yarn.
- **Shell**: [`dot_zshrc`](../dot_zshrc) initializes Homebrew PATH, Oh My Zsh (when present), **Powerlevel10k** (Tokyo Night–tuned [`dot_p10k.zsh`](../dot_p10k.zsh)), then shared extras. **`dot_zshrc` must source `~/.p10k.zsh` after OMZ** — without it, p10k re-runs the configuration wizard on every new terminal tab. Put secrets in `~/.zshrc.local` (gitignored pattern).
- **Bootstrap**: [`macos/install.sh`](../macos/install.sh) runs `brew bundle`, [`scripts/install-omz-p10k.sh`](../scripts/install-omz-p10k.sh), Cursor/VS Code extensions, and optionally `rcup` when rcm is present; **chezmoi** is the canonical dotfile path—run `chezmoi apply` with this repo as your source (see [README](../README.md)). Post-setup: [`macos/verify.sh`](../macos/verify.sh).
- **Window tiling**: **Rectangle** ([`Brewfile`](../Brewfile) cask `rectangle`) — not Slate. Configure shortcuts in Rectangle → Settings after install. Linux XFCE/Mint uses **Super+Left/Right** via wmctrl scripts ([`linux/xfce-ux-mint.sh`](../linux/xfce-ux-mint.sh)); on macOS use Rectangle’s defaults (e.g. **Ctrl+Option+arrow** for halves) or your own bindings.

### Arch Linux (typical laptop)

- **packages.txt**: `kitty`, `bat`, `ripgrep`, `fd`, `eza`, `lnav`, etc. via [`arch/bootstrap.sh`](../arch/bootstrap.sh) (`pacman`). **Starship** is not installed here (zsh uses p10k).
- [`arch/bootstrap.sh`](../arch/bootstrap.sh) clones Powerlevel10k into `~/.oh-my-zsh/custom/themes` and runs `chezmoi apply`.

### Linux Mint 22.x (Ubuntu Noble) / Debian-family

- **Bootstrap**: [`linux/bootstrap.sh`](../linux/bootstrap.sh) — APT packages, **chezmoi**, **uv**, **Starship**, Oh My Zsh, Powerlevel10k. Use `--laptop` for TLP/powertop ([`linux/mint-apt-laptop.txt`](../linux/mint-apt-laptop.txt)). Lighter alternative: [`linux/mint-bootstrap.sh`](../linux/mint-bootstrap.sh) (APT + OMZ/p10k + `chezmoi apply` only).
- **APT list**: [`linux/mint-apt-cli.txt`](../linux/mint-apt-cli.txt) — same packages as copy-paste reference.
- **Shell**: **bash** → [`dot_bashrc`](../dot_bashrc) (Starship + Mint `command-not-found`). **zsh** → [`dot_zshrc`](../dot_zshrc) + **Powerlevel10k**.
- **Autostart / stalling login**: entries under `~/.config/autostart/` that point to missing AppImages, moved paths, or broken `Exec=` lines (VPN clients like Outline, cloud sync, etc.) can hang or slow the session and flood logs. Inspect with `ls ~/.config/autostart/`, open each `.desktop` file, and remove or fix stale entries. Paths with spaces or non-ASCII directory names are easy to break—quote `Exec=` correctly or use wrappers.

### XFCE (Linux Mint / Ubuntu XFCE), optional

Lean desktop polish (theme/icons/cursor, Qt via **qt5ct**, Thunar archive integration, Super+arrow tiling keys, **Kitty as default terminal**)—does **not** change GTK fonts.

- **Script**: [`linux/xfce-ux-mint.sh`](../linux/xfce-ux-mint.sh) — run inside a graphical session (`DISPLAY` set). Installs APT packages from [`linux/mint-apt-xfce-ux.txt`](../linux/mint-apt-xfce-ux.txt), sets **Kitty** as XFCE default terminal (`exo-preferred-applications`), then applies xfconf (Arc-Dark / Papirus / Bibata cursor, `tile_on_move`, xfwm4 shortcuts). Flags: `--apt-only`, `--xfconf-only`.
- **Kitty**: [`dot_config/kitty/kitty.conf`](../dot_config/kitty/kitty.conf) — Tokyo Night–adjacent colors, JetBrains Mono Nerd Font, `shell=zsh`.
- **Arch (same ideas, manual)**: [`linux/arch-pkg-xfce-ux.txt`](../linux/arch-pkg-xfce-ux.txt) — `sudo pacman -S --needed - < linux/arch-pkg-xfce-ux.txt` (not wired into [`arch/bootstrap.sh`](../arch/bootstrap.sh)).
- **Chezmoi**: [`dot_config/environment.d/10-qt-theme.conf`](../dot_config/environment.d/10-qt-theme.conf) sets `QT_QPA_PLATFORMTHEME=qt5ct`. Install **qt6ct** and switch that variable to `qt6ct` if you rely on Qt6 apps without qt5ct compatibility. Run **qt5ct** once after install.
- **Thunar**: [`dot_config/Thunar/uca.xml`](../dot_config/Thunar/uca.xml) adds “Open Terminal Here” (**Kitty**). If you already use custom actions, merge carefully or back up `~/.config/Thunar/uca.xml` before `chezmoi apply`.
- **Whisker Menu (required)**: Linux Mint ships **Super alone → whiskermenu** in `mint-artwork` defaults. That grab blocks **xfwm4 Super+arrow** on X11 (libxfce4ui fires on key press, not release). The script overrides **Super_L** with `/usr/bin/true`, binds Whisker to **Super+Space**, and tiles via **wmctrl scripts** on **Super+Left/Right** (application shortcuts, not xfwm4).
- **Super+Right / Super+r**: Mint’s default **Super+r** (`xfce4-appfinder -c`) is overridden with **`/usr/bin/true`**; **Super+Page Down** opens the collapsed app finder. **Alt+F3** = full finder.
- **Tiling scripts**: [`linux/bin/xfce-tile-left.sh`](../linux/bin/xfce-tile-left.sh), [`linux/bin/xfce-tile-right.sh`](../linux/bin/xfce-tile-right.sh), [`linux/bin/xfce-window-maximize.sh`](../linux/bin/xfce-window-maximize.sh), [`linux/bin/xfce-window-restore.sh`](../linux/bin/xfce-window-restore.sh) — installed to `~/.local/bin/` by [`linux/xfce-ux-mint.sh`](../linux/xfce-ux-mint.sh). **Super+Up** maximizes; **Super+Down** restores default size. Requires **wmctrl** ([`linux/mint-apt-xfce-ux.txt`](../linux/mint-apt-xfce-ux.txt)).
- **macOS parity**: No XFCE automation—terminal/font story stays **iTerm2** + Nerd Font from [`Brewfile`](../Brewfile); this block is Linux-only.

### Steam Deck / SteamOS

- **Do not** run [`arch/bootstrap.sh`](../arch/bootstrap.sh) blindly: SteamOS is not a generic Arch laptop; root may be immutable and updates are SteamOS-managed.
- **Safe**: **User-level** configs only (`chezmoi apply` from your dotfiles source, or copy `dot_*` equivalents into `~/.config` and home).
- **Packages**: Prefer **distrobox**, **Flatpak**, or Deck-specific docs for CLIs; avoid `sudo pacman -Syu` on the host without checking Valve’s current guidance.

## Fonts (JetBrains Mono + Nerd)

Powerlevel10k and Starship icons use **Nerd Font** codepoints. If the terminal’s font is not a Nerd-patched face, you get **empty boxes** or missing glyphs in the prompt.

- **macOS**: Cask `font-jetbrains-mono-nerd-font` in [`Brewfile`](../Brewfile). In **iTerm2**: Settings → Profiles → Text → **Font** → choose **JetBrainsMono Nerd Font** (or **NF**).
- **Linux — apt alone is not enough**: `sudo apt install fonts-jetbrains-mono` installs the **upstream** JetBrains Mono family from Google, **without** Nerd icons. For glyphs you need a **Nerd Fonts** build.

### Linux: install JetBrains Mono Nerd (user fonts, no root)

Run the helper script (idempotent):

```bash
bash linux/install-nerd-font-jetbrains.sh
```

Or manually: download **`JetBrainsMono.zip`** from [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases), extract `.ttf` files to `~/.local/share/fonts/JetBrainsMono`, then `fc-cache -fv ~/.local/share/fonts`.

Confirm: `fc-list | grep -i 'JetBrainsMono.*Nerd Font'`.

### Point terminals at the Nerd Font

- **Kitty** (default on Mint/XFCE): configured in [`dot_config/kitty/kitty.conf`](../dot_config/kitty/kitty.conf) — **JetBrainsMono Nerd Font** size 13.
- **xfce4-terminal** (fallback): set font in preferences if you still use it.
- **Cursor / VS Code**: the **integrated terminal does not** use the GUI terminal’s font. **Chezmoi** installs Cursor user settings (Tokyo Night + **JetBrainsMono Nerd Font** for editor + integrated terminal). The JSON lives once in [`.chezmoi/templates/cursor-user-settings.json`](../.chezmoi/templates/cursor-user-settings.json); Linux and macOS each use a small [`settings.json.tmpl`](../dot_config/Cursor/User/settings.json.tmpl) under [`dot_config/Cursor/User/`](../dot_config/Cursor/User/) or [`Library/Application Support/Cursor/User/`](../Library/Application%20Support/Cursor/User/) (see [`.chezmoiignore`](../.chezmoiignore) for OS-specific apply). Install the theme extension once: `cursor --install-extension enkia.tokyo-night` (or via Extensions). You can still override in **Settings** (JSON), e.g.  
  `"terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font', monospace"`
- **Kitty / Tilix / GNOME Terminal**: choose the **Nerd Font** family in that app’s font preferences (Kitty is preconfigured via chezmoi).

This repo does not ship the binary font files (copyright/size); install once per machine and select the face above.

## Git config (`dot_gitconfig.tmpl`)

- **Global excludes**: `core.excludesfile` → `~/.config/git/ignore` ([`dot_config/git/ignore`](../dot_config/git/ignore)).
- **Credential helper**: **macOS** `osxkeychain`; **Linux** `cache` by default. Override with `git config --global credential.helper store` or `libsecret` if you prefer.
- **Editor**: **macOS** `code --wait`; **Linux** `vim`. Override with `git config --global core.editor …` or a local include.

## Verify

Run the automated checker:

```bash
# Linux Mint
bash linux/verify.sh

# macOS
bash macos/verify.sh
```

Manual spot-checks:

1. **Chezmoi**: `chezmoi apply --dry-run` then `chezmoi apply`.
2. **zsh / Powerlevel10k**: New zsh session shows rainbow/Tokyo Night–style two-line prompt.
3. **bash / Starship**: `bash -il` shows Tokyo Night ribbon prompt from [`starship.toml`](../dot_config/starship.toml).
4. **Non-interactive**: `zsh -c 'alias cat'` should not define `cat` from extras.
5. **tmux**: `tmux` → `Ctrl-b` then `|` / `-` for splits, `r` reloads config.
6. **Kitty default**: `xfconf-query -c exo-preferred-applications -p /TerminalEmulator` → `kitty`.
7. **Nerd Font**: `fc-list | grep -i 'JetBrainsMono.*Nerd Font'`; Cursor integrated terminal shows glyphs.

## Manual steps that may remain

- Install [Oh My Zsh](https://ohmyz.sh/) and clone Powerlevel10k if [`linux/bootstrap.sh`](../linux/bootstrap.sh), [`macos/install.sh`](../macos/install.sh), or [`arch/bootstrap.sh`](../arch/bootstrap.sh) has not already done so.
- On Steam Deck, choose distrobox vs host for CLIs per Valve’s current guidance.
