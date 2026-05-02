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

### XFCE (Linux Mint / Ubuntu XFCE), optional

Lean desktop polish (theme/icons/cursor, Qt via **qt5ct**, Thunar archive integration, Super+arrow tiling keys)—does **not** change GTK fonts or install Kitty.

- **Script**: [`linux/xfce-ux-mint.sh`](../linux/xfce-ux-mint.sh) — run inside a graphical session (`DISPLAY` set). Installs APT packages from [`linux/mint-apt-xfce-ux.txt`](../linux/mint-apt-xfce-ux.txt), then applies xfconf (Arc-Dark / Papirus / Bibata cursor, `tile_on_move`, xfwm4 `/xfwm4/custom/` shortcuts). Flags: `--apt-only`, `--xfconf-only`.
- **Arch (same ideas, manual)**: [`linux/arch-pkg-xfce-ux.txt`](../linux/arch-pkg-xfce-ux.txt) — `sudo pacman -S --needed - < linux/arch-pkg-xfce-ux.txt` (not wired into [`arch/bootstrap.sh`](../arch/bootstrap.sh)).
- **Chezmoi**: [`dot_config/environment.d/10-qt-theme.conf`](../dot_config/environment.d/10-qt-theme.conf) sets `QT_QPA_PLATFORMTHEME=qt5ct`. Install **qt6ct** and switch that variable to `qt6ct` if you rely on Qt6 apps without qt5ct compatibility. Run **qt5ct** once after install.
- **Thunar**: [`dot_config/Thunar/uca.xml`](../dot_config/Thunar/uca.xml) adds “Open Terminal Here” (`xfce4-terminal`). If you already use custom actions, merge carefully or back up `~/.config/Thunar/uca.xml` before `chezmoi apply`.
- **Super vs Whisker**: On X11, binding **Whisker Menu to Super alone** can prevent **Super+arrow** shortcuts from reaching xfwm4. Prefer Whisker on **Super+Space** or similar if tiling keys do nothing.
- **Super+Right only broken**: Mint’s default **Super+r** (`xfce4-appfinder -c`) must be fully overridden—an empty custom shortcut can still leave the **default** active. The script sets `/commands/custom/<Super>r` to **`/usr/bin/true`**, clears `/commands/default/<Super>r`, and binds **Super+Page Down** to `xfce4-appfinder -c`. **Alt+F3** still opens the full app finder.
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

1. Download **`JetBrainsMono.zip`** from [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases) (same family used elsewhere in this repo).
2. Install into your user font directory and refresh the cache:

   ```bash
   mkdir -p ~/.local/share/fonts/JetBrainsMono
   unzip -q JetBrainsMono.zip -d /tmp/jbm
   find /tmp/jbm -name '*.ttf' -exec cp -t ~/.local/share/fonts/JetBrainsMono {} +
   fc-cache -fv ~/.local/share/fonts
   ```

3. Confirm Fontconfig sees it: `fc-list | grep -i 'JetBrainsMono.*Nerd Font'` — you should see **`JetBrainsMono Nerd Font`** / **`JetBrainsMono NF`**.

### Point terminals at the Nerd Font

- **xfce4-terminal** (XFCE / Mint): **Edit → Preferences → your profile → Font** → **JetBrainsMono Nerd Font** (pick size, e.g. 13). Alternatively (applies to default profile):  
  `xfconf-query -c xfce4-terminal -p /font-name -s "JetBrainsMono Nerd Font 13"`
- **Cursor / VS Code**: the **integrated terminal does not** use the GUI terminal’s font. **Chezmoi** installs Cursor user settings (Tokyo Night + **JetBrainsMono Nerd Font** for editor + integrated terminal). The JSON lives once in [`.chezmoi/templates/cursor-user-settings.json`](../.chezmoi/templates/cursor-user-settings.json); Linux and macOS each use a small [`settings.json.tmpl`](../dot_config/Cursor/User/settings.json.tmpl) under [`dot_config/Cursor/User/`](../dot_config/Cursor/User/) or [`Library/Application Support/Cursor/User/`](../Library/Application%20Support/Cursor/User/) (see [`.chezmoiignore`](../.chezmoiignore) for OS-specific apply). Install the theme extension once: `cursor --install-extension enkia.tokyo-night` (or via Extensions). You can still override in **Settings** (JSON), e.g.  
  `"terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font', monospace"`
- **Kitty / Tilix / GNOME Terminal**: same idea — choose the **Nerd Font** family in that app’s font preferences.

This repo does not ship the binary font files (copyright/size); install once per machine and select the face above.

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
7. **Nerd Font (Linux / Cursor)**: `fc-list | grep -i 'JetBrainsMono.*Nerd Font'`; integrated terminal shows icons only after **`terminal.integrated.fontFamily`** (Cursor/VS Code) matches the installed Nerd face.

## Manual steps that may remain

- Install [Oh My Zsh](https://ohmyz.sh/) and clone Powerlevel10k (see [README](../README.md)) if `arch/bootstrap.sh` / Mint bootstrap has not already done so.
- On Steam Deck, choose distrobox vs host for CLIs per Valve’s current guidance.
