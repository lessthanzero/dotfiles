# Some of my setup files

Heavily based on Anton Vasin's [dotfiles repo](https://github.com/antonvasin/dotfiles) and David Echols' [Macbot](https://github.com/echohack/macbot), and similar [repo](https://github.com/mathieudutour/dotfiles) by Mathieu Dutour.

## How dotfiles are applied

**Chezmoi** is the canonical path: `dot_*` files in this repo render to `~` (e.g. `dot_zshrc` → `~/.zshrc`). Run `chezmoi init` / `chezmoi apply` with this repo as your source.

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

**rcm** ([thoughtbot/rcm](https://github.com/thoughtbot/rcm)) is optional legacy tooling: `rcup` only if you use an rcm layout. If you use chezmoi, you do not need `rcup`.

[`macos/install.sh`](macos/install.sh) runs `brew bundle` and may run `rcup` when `rcm` is installed; **chezmoi users** should run **`chezmoi apply`** separately after pointing chezmoi at this repo.

### By platform

| Platform | Packages / bootstrap | Dotfiles |
|----------|------------------------|----------|
| **macOS** | [`Brewfile`](Brewfile) via `brew bundle` (optional: [`macos/install.sh`](macos/install.sh)) | `chezmoi apply` (same `dot_*` as everywhere) |
| **Arch (typical laptop)** | [`packages.txt`](packages.txt) + [`arch/bootstrap.sh`](arch/bootstrap.sh) (`pacman` + `chezmoi apply`) | `chezmoi apply` |
| **Linux Mint / Debian** | [`linux/bootstrap-cli.sh`](linux/bootstrap-cli.sh) (APT + chezmoi/uv/starship installers); package list: [`linux/mint-apt-cli.txt`](linux/mint-apt-cli.txt) | `chezmoi apply`; bash → [`dot_bashrc`](dot_bashrc), zsh → [`dot_zshrc`](dot_zshrc) |
| **XFCE UX (optional)** | Mint/Ubuntu: [`linux/xfce-ux-mint.sh`](linux/xfce-ux-mint.sh) + [`linux/mint-apt-xfce-ux.txt`](linux/mint-apt-xfce-ux.txt). Arch (manual): [`linux/arch-pkg-xfce-ux.txt`](linux/arch-pkg-xfce-ux.txt) | Same `chezmoi apply` — adds `~/.config/environment.d/` (Qt) and Thunar custom action |
| **Steam Deck / SteamOS** | **Do not** run [`arch/bootstrap.sh`](arch/bootstrap.sh) as a full Arch script; install CLIs via distrobox/flatpak if needed | `chezmoi apply` for user-level configs only |

Details, verification, and caveats: [docs/terminal-ux.md](docs/terminal-ux.md).

### Zsh: Oh My Zsh + Powerlevel10k (Tokyo Night)

Chezmoi installs [`dot_p10k.zsh`](dot_p10k.zsh) as `~/.p10k.zsh`. Install [Oh My Zsh](https://ohmyz.sh/) first, then the theme:

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

[`arch/bootstrap.sh`](arch/bootstrap.sh) clones Powerlevel10k into `~/.oh-my-zsh/custom/themes` when you run it. [`linux/bootstrap-cli.sh`](linux/bootstrap-cli.sh) prints the same hint after installing APT packages.

Use a [Nerd Font](https://www.nerdfonts.com/) in your terminal (e.g. **JetBrains Mono Nerd** — macOS: [`Brewfile`](Brewfile) cask `font-jetbrains-mono-nerd-font`; Linux: install from [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases) and set the font in **xfce4-terminal**, **Cursor**, etc. — full steps in [`docs/terminal-ux.md`](docs/terminal-ux.md) under **Fonts (JetBrains Mono + Nerd)**).

**Bash** still uses [Starship](https://starship.rs/) with the Tokyo Night preset ([`dot_config/starship.toml`](dot_config/starship.toml)); install Starship via [`linux/bootstrap-cli.sh`](linux/bootstrap-cli.sh) or your package manager.
