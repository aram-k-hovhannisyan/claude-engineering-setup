"""Add an HTTP MCP server to the user-level Claude Code config (~/.claude.json).

Used when the `claude` CLI is not on PATH (for example VS Code extension only).
Usage: python add_mcp_server.py <name> <url>
"""

import json
import pathlib
import shutil
import sys
import time


def main():
    name, url = sys.argv[1], sys.argv[2]
    config = pathlib.Path.home() / ".claude.json"

    data = {}
    if config.exists():
        data = json.loads(config.read_text(encoding="utf-8"))

    servers = data.setdefault("mcpServers", {})
    if servers.get(name, {}).get("url") == url:
        print(f"MCP server '{name}' already configured")
        return

    if config.exists():
        backup = config.with_name(f".claude.json.backup-{time.strftime('%Y%m%d-%H%M%S')}")
        shutil.copy2(config, backup)
        print(f"Backed up  {config} -> {backup.name}")

    servers[name] = {"type": "http", "url": url}
    config.write_text(json.dumps(data, indent=2), encoding="utf-8")
    print(f"Added MCP server '{name}' ({url})")


if __name__ == "__main__":
    main()
