#!/usr/bin/env bash
# Installs the engineering team setup into ~/.claude (macOS / Linux / Git Bash).
# Usage:  ./install.sh [--no-graphify]

set -euo pipefail

source_dir="$(cd "$(dirname "$0")" && pwd)/claude"
target="$HOME/.claude"
backup="$target/backups/engineering-setup-$(date +%Y%m%d-%H%M%S)"
install_graphify=1

if [ "${1:-}" = "--no-graphify" ]
then
    install_graphify=0
fi

mkdir -p "$target/agents" "$target/skills"

# Everything this installer will overwrite, relative to ~/.claude.
items="CLAUDE.md team"
for f in "$source_dir"/agents/* "$source_dir"/skills/*
do
    items="$items ${f#"$source_dir"/}"
done

for item in $items
do
    if [ -e "$target/$item" ]
    then
        mkdir -p "$(dirname "$backup/$item")"
        mv "$target/$item" "$backup/$item"
        echo "Backed up  $item"
    fi

    cp -R "$source_dir/$item" "$target/$item"
    echo "Installed  $item"
done

if [ "$install_graphify" -eq 1 ]
then
    echo
    echo "Installing graphify (codebase knowledge-graph skill)..."
    if ! command -v graphify >/dev/null 2>&1
    then
        if command -v uv >/dev/null 2>&1
        then
            uv tool install graphifyy || true
        else
            python3 -m pip install --user graphifyy || true
        fi
    fi

    if ! graphify install --platform claude
    then
        echo "WARNING: graphify was not installed."
        echo "Install it later with:  pip install graphifyy && graphify install --platform claude"
    fi
fi

echo
if [ -d "$backup" ]
then
    echo "Previous files saved in $backup"
fi
echo "Done. Restart Claude Code so it loads the new agents and skills."
