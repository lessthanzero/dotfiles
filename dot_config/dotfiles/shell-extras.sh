# Shared interactive-only aliases (sourced from ~/.zshrc / ~/.bashrc).
# Non-interactive shells must not load this file's effects; guard is below.
case $- in *i*) ;; *) return ;; esac

# bat: Debian/Ubuntu package often installs `batcat`; Arch/macOS use `bat`.
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never'
fi

# ripgrep
if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
fi

# fd: Debian `fd-find` provides `fdfind` when `fd` is taken
if command -v fd >/dev/null 2>&1; then
  :
elif command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

# eza: only when installed (optional on all platforms)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -la'
  alias la='eza -a'
  alias lt='eza --tree'
fi
