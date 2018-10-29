!/usr/bin/env bash

echo -e 'Setting up dotfiles…\n'

# Run mac OS configuration

echo "⚙️  Configuring mac OS…" ./osx
# Check and install homebrew if needed
if ! which -s brew > /dev/null; then
  echo '🛠  Installing Homebrew…'
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo '🛠  Installing software…'
brew bundle

echo '🛠  Installing dotfiles…'
rcup