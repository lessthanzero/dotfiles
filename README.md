# Some of my setup files

Heavily based on Anton Vasin's [dotfiles repo](https://github.com/antonvasin/dotfiles) and David Echols' [Macbot](https://github.com/echohack/macbot), and similar [repo](https://github.com/mathieudutour/dotfiles) by Mathieu Dutour.

## How dotfiles are applied

**Chezmoi** is the canonical path: `dot_*` files in this repo render to `~` (e.g. `dot_zshrc` → `~/.zshrc`). Run `chezmoi init` / `chezmoi apply` with this repo as your source. Shared snippets used by multiple targets live under `.chezmoi/templates/` (for example Cursor user settings pulled in by `settings.json.tmpl`).

### First-time chezmoi (new machine)

Install [chezmoi](https://www.chezmoi.io/install/), then clone and apply this repo in one step:

```bash
chezmoi init --apply https://github.com/lessthanzero/dotfiles.git
```

With SSH:

```bash
chezmoi init --apply git@github.com:lessthanzero/dotfiles.git
```

Later, refresh from git: `chezmoi update && chezmoi apply`, or `git pull` inside `$(chezmoi source-path)` (often `~/.local/share/chezmoi`) then `chezmoi apply`.

[`macos/install.sh`](macos/install.sh) runs `brew bundle`, Oh My Zsh + Powerlevel10k ([`scripts/install-omz-p10k.sh`](scripts/install-omz-p10k.sh)); **chezmoi users** should run **`chezmoi apply`** separately after pointing chezmoi at this repo.

### By platform

| Platform | Packages / bootstrap | Dotfiles |
|----------|------------------------|----------|
| **macOS** | [`macos/Brewfile`](macos/Brewfile) via `brew bundle` (optional: [`macos/install.sh`](macos/install.sh)) | `chezmoi apply` (same `dot_*` as everywhere) |
| **Arch (typical laptop)** | [`packages.txt`](packages.txt) + [`arch/bootstrap.sh`](arch/bootstrap.sh) (`pacman` + `chezmoi apply`) | `chezmoi apply` |
| **Linux Mint / Debian** | [`linux-mint/bootstrap.sh`](linux-mint/bootstrap.sh) (APT + chezmoi/uv/starship + OMZ + p10k; `--laptop` for TLP). Package list: [`linux-mint/mint-apt-cli.txt`](linux-mint/mint-apt-cli.txt) | `chezmoi apply`; bash → [`dot_bashrc`](dot_bashrc), zsh → [`dot_zshrc`](dot_zshrc) |
| **Fedora Kinoite (Atomic)**| [`fedora-kinoite/bootstrap.sh`](fedora-kinoite/bootstrap.sh) (`rpm-ostree` + `flatpak` + `podman` + `brew`) | `chezmoi apply` |
| **XFCE UX (optional)** | Mint/Ubuntu: [`linux-mint/xfce-ux-mint.sh`](linux-mint/xfce-ux-mint.sh) + [`linux-mint/mint-apt-xfce-ux.txt`](linux-mint/mint-apt-xfce-ux.txt). Arch (manual): [`linux/arch-pkg-xfce-ux.txt`](linux/arch-pkg-xfce-ux.txt) | Same `chezmoi apply` — adds `~/.config/environment.d/` (Qt) and Thunar custom action |
| **Steam Deck / SteamOS** | **Do not** run [`arch/bootstrap.sh`](arch/bootstrap.sh) as a full Arch script; install CLIs via distrobox/flatpak if needed | `chezmoi apply` for user-level configs only |

Details, verification, and caveats: [docs/terminal-ux.md](docs/terminal-ux.md).

### Linux Mint scripts (which to run)

| Script | Use on |
|--------|--------|
| [`linux-mint/bootstrap.sh`](linux-mint/bootstrap.sh) | **Your dev laptops** — CLI tools, chezmoi, OMZ, p10k (`--laptop` adds TLP) |
| [`linux-mint/xfce-ux-mint.sh`](linux-mint/xfce-ux-mint.sh) | Optional XFCE polish — themes, **Kitty default terminal**, Super+arrow tiling |
| [`linux-mint/install-nerd-font-jetbrains.sh`](linux-mint/install-nerd-font-jetbrains.sh) | JetBrains Mono Nerd Font (user fonts) |
| [`linux-mint/verify.sh`](linux-mint/verify.sh) | Post-setup sanity checks |
| [`linux-mint/bootstrap-cli.sh`](linux-mint/bootstrap-cli.sh) | APT CLI only (called by `bootstrap.sh`) |
| [`linux-mint/mint-bootstrap.sh`](linux-mint/mint-bootstrap.sh) | Minimal Mint path — APT + OMZ/p10k + `chezmoi apply` |
| [`linux-mint/linux-xfce-setup.sh`](linux-mint/linux-xfce-setup.sh) | **Parents laptop only** — hostname, swap, VPN, etc. Do not run on dev machines |

### Fedora Kinoite scripts (which to run)

| Script | Use on |
|--------|--------|
| [`fedora-kinoite/bootstrap.sh`](fedora-kinoite/bootstrap.sh) | **Fedora Kinoite workstation** — rpm-ostree packages, flatpaks, Homebrew, Ollama, OMZ, p10k |
| [`fedora-kinoite/verify.sh`](fedora-kinoite/verify.sh) | Post-setup sanity checks |

### macOS scripts

| Script | Use on |
|--------|--------|
| [`macos/install.sh`](macos/install.sh) | Full Mac bootstrap — Homebrew, OMZ + p10k, system defaults, MAS apps |
| [`macos/verify.sh`](macos/verify.sh) | Post-setup sanity checks |
| [`scripts/install-omz-p10k.sh`](scripts/install-omz-p10k.sh) | Shared Oh My Zsh + Powerlevel10k install (called by macOS and Linux bootstrap) |

### Zsh: Oh My Zsh + Powerlevel10k (Tokyo Night)

Chezmoi installs [`dot_p10k.zsh`](dot_p10k.zsh) as `~/.p10k.zsh`. Install [Oh My Zsh](https://ohmyz.sh/) first, then the theme:

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

[`arch/bootstrap.sh`](arch/bootstrap.sh) clones Powerlevel10k into `~/.oh-my-zsh/custom/themes` when you run it. [`linux-mint/bootstrap.sh`](linux-mint/bootstrap.sh) does the same on Mint/Debian, and [`fedora-kinoite/bootstrap.sh`](fedora-kinoite/bootstrap.sh) does it on Kinoite.

Use a [Nerd Font](https://www.nerdfonts.com/) in your terminal (e.g. **JetBrains Mono Nerd** — macOS: [`macos/Brewfile`](macos/Brewfile) cask `font-jetbrains-mono-nerd-font`; Linux: [`linux-mint/install-nerd-font-jetbrains.sh`](linux-mint/install-nerd-font-jetbrains.sh) or [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases)). On Linux Mint/XFCE, **[Kitty](https://sw.kovidgoyal.net/kitty/)** is the default terminal ([`dot_config/kitty/kitty.conf`](dot_config/kitty/kitty.conf)); also set in **Cursor** — full steps in [`docs/terminal-ux.md`](docs/terminal-ux.md).

**Bash** still uses [Starship](https://starship.rs/) with the Tokyo Night preset ([`dot_config/starship.toml`](dot_config/starship.toml)); install Starship via [`linux-mint/bootstrap.sh`](linux-mint/bootstrap.sh) or your package manager.
