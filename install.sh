#!/usr/bin/env bash
# Installs the engineering team setup into ~/.claude (macOS / Linux / Git Bash).
# Usage:  ./install.sh [--no-ross] [--no-graphify]

set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
source_dir="$repo_dir/claude"
target="$HOME/.claude"
backup="$target/backups/engineering-setup-$(date +%Y%m%d-%H%M%S)"
install_ross=1
install_graphify=1

for arg in "$@"
do
    case "$arg" in
        --no-ross)
            install_ross=0
            ;;
        --no-graphify)
            install_graphify=0
            ;;
    esac
done

backup_item()
{
    if [ -e "$target/$1" ]
    then
        mkdir -p "$(dirname "$backup/$1")"
        mv "$target/$1" "$backup/$1"
        echo "Backed up  $1"
    fi
}

mkdir -p "$target/agents" "$target/skills"

# Everything this installer will overwrite, relative to ~/.claude.
items="CLAUDE.md team"
for f in "$source_dir"/agents/* "$source_dir"/skills/*
do
    items="$items ${f#"$source_dir"/}"
done

for item in $items
do
    backup_item "$item"
    cp -R "$source_dir/$item" "$target/$item"
    echo "Installed  $item"
done

if [ "$install_ross" -eq 1 ]
then
    echo
    echo "Installing AMD Ross skills (pinned commit, listed in ross-skills.txt)..."
    lines="$(grep -v -e '^#' -e '^[[:space:]]*$' "$repo_dir/ross-skills.txt" | tr -d '\r')"
    commit="$(echo "$lines" | sed -n 's/^commit[[:space:]]*//p')"
    ross_skills="$(echo "$lines" | grep -v '^commit')"
    ross_dir="$(mktemp -d)"

    git init -q "$ross_dir"
    git -C "$ross_dir" fetch -q --depth 1 https://github.com/Xilinx/ross-ai-assistant.git "$commit"
    git -C "$ross_dir" -c advice.detachedHead=false checkout -q FETCH_HEAD

    for skill in $ross_skills
    do
        backup_item "skills/$skill"
        cp -R "$ross_dir/skills/$skill" "$target/skills/$skill"
        cp "$ross_dir/LICENSE" "$target/skills/$skill/LICENSE-AMD-ROSS"
        echo "Installed  skills/$skill"
    done
    rm -rf "$ross_dir"

    # AMD documentation search MCP server, used by the vendor-docs agent.
    mcp_url="https://ross.amd.com/mcp/doc-search"
    if command -v claude >/dev/null 2>&1
    then
        claude mcp add --transport http --scope user amd-doc-search "$mcp_url" || true
    elif command -v python3 >/dev/null 2>&1
    then
        python3 "$repo_dir/scripts/add_mcp_server.py" amd-doc-search "$mcp_url"
    else
        echo "WARNING: add the AMD doc-search MCP server later:"
        echo "  claude mcp add --transport http --scope user amd-doc-search $mcp_url"
    fi
fi

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
