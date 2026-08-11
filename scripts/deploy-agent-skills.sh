#!/usr/bin/env bash
# Deploy canonical skills from dotfiles/skills/ to all AI runtimes.
set -euo pipefail

SOURCE="${CHEZMOI_SOURCE_DIR:-${HOME}/Developer/dotfiles}/skills"
TARGETS=(
  "${HOME}/.cursor/skills"
  "${HOME}/.gemini/config/skills"
  "${HOME}/.codex/skills"
  "${HOME}/.claude/skills"
)

if [[ ! -d "$SOURCE" ]]; then
  echo "ERROR: skills source not found: $SOURCE" >&2
  exit 1
fi

deployed=0
for skill_dir in "$SOURCE"/*/; do
  [[ -d "$skill_dir" ]] || continue
  [[ -f "${skill_dir}SKILL.md" ]] || continue
  name="$(basename "$skill_dir")"
  [[ "$name" == "catalog.yaml" ]] && continue

  for target in "${TARGETS[@]}"; do
    mkdir -p "${target}/${name}"
    cp "${skill_dir}SKILL.md" "${target}/${name}/SKILL.md"
    if [[ -f "${skill_dir}reference.md" ]]; then
      cp "${skill_dir}reference.md" "${target}/${name}/reference.md"
    fi
    if [[ -d "${skill_dir}scripts" ]]; then
      rm -rf "${target}/${name}/scripts"
      cp -R "${skill_dir}scripts" "${target}/${name}/"
    fi
    if [[ -f "${skill_dir}repos.yaml" ]]; then
      cp "${skill_dir}repos.yaml" "${target}/${name}/repos.yaml"
    fi
  done
  deployed=$((deployed + 1))
  echo "Deployed skill: $name"
done

if [[ "$deployed" -eq 0 ]]; then
  echo "ERROR: no skills found under $SOURCE" >&2
  exit 1
fi

missing=0
for target in "${TARGETS[@]}"; do
  if [[ ! -d "$target" ]]; then
    echo "ERROR: mandatory deploy target missing: $target" >&2
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo "Deployed $deployed skill(s) to Cursor, Antigravity, Codex, and Claude Code."
