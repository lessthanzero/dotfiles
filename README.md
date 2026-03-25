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
| **Linux Mint / Debian** | APT: see [`linux/mint-apt-cli.txt`](linux/mint-apt-cli.txt) | `chezmoi apply`; bash → [`dot_bashrc`](dot_bashrc), zsh → [`dot_zshrc`](dot_zshrc) |
| **Steam Deck / SteamOS** | **Do not** run [`arch/bootstrap.sh`](arch/bootstrap.sh) as a full Arch script; install CLIs via distrobox/flatpak if needed | `chezmoi apply` for user-level configs only |

Details, verification, and caveats: [docs/terminal-ux.md](docs/terminal-ux.md).
