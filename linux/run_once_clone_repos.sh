#!/usr/bin/env bash
set -e

mkdir -p ~/Documents
mkdir -p ~/Developer

if [ ! -d ~/Documents/vault-mirror ]; then
  gh repo clone lessthanzero/vault-mirror ~/Documents/vault-mirror
fi

if [ ! -d ~/Developer/personal-website ]; then
  gh repo clone lessthanzero/personal-website ~/Developer/personal-website
fi
