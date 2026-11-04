# Installs the engineering team setup into ~/.claude (Windows PowerShell 5.1+).
# Usage:  powershell -ExecutionPolicy Bypass -File install.ps1 [-NoRoss] [-NoGraphify]

param(
    [switch]$NoRoss,
    [switch]$NoGraphify
)

$ErrorActionPreference = "Stop"

$source = Join-Path $PSScriptRoot "claude"
$target = Join-Path $HOME ".claude"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backup = Join-Path $target "backups\engineering-setup-$stamp"

New-Item -ItemType Directory -Force (Join-Path $target "agents") | Out-Null
New-Item -ItemType Directory -Force (Join-Path $target "skills") | Out-Null

# Everything this installer will overwrite, relative to ~/.claude.
$items = @("CLAUDE.md", "team")
$items += Get-ChildItem (Join-Path $source "agents") | ForEach-Object { "agents\" + $_.Name }
$items += Get-ChildItem (Join-Path $source "skills") | ForEach-Object { "skills\" + $_.Name }

foreach ($item in $items)
{
    $existing = Join-Path $target $item
    if (Test-Path $existing)
    {
        $saved = Join-Path $backup $item
        New-Item -ItemType Directory -Force (Split-Path $saved) | Out-Null
        Move-Item $existing $saved
        Write-Host "Backed up  $item"
    }

    Copy-Item (Join-Path $source $item) $existing -Recurse
    Write-Host "Installed  $item"
}

if (-not $NoRoss)
{
    Write-Host ""
    Write-Host "Installing AMD Ross skills (pinned commit, listed in ross-skills.txt)..."
    $lines = Get-Content (Join-Path $PSScriptRoot "ross-skills.txt") | Where-Object { $_ -and -not $_.StartsWith("#") }
    $commit = ($lines | Where-Object { $_.StartsWith("commit ") }) -replace "^commit\s+", ""
    $rossSkills = $lines | Where-Object { -not $_.StartsWith("commit ") }
    $rossDir = Join-Path ([System.IO.Path]::GetTempPath()) "ross-ai-assistant-$stamp"

    git init -q $rossDir
    git -C $rossDir fetch -q --depth 1 https://github.com/Xilinx/ross-ai-assistant.git $commit
    git -C $rossDir -c advice.detachedHead=false checkout -q FETCH_HEAD
    if ($LASTEXITCODE -ne 0)
    {
        throw "Could not download AMD Ross skills (commit $commit)."
    }

    foreach ($skill in $rossSkills)
    {
        $item = "skills\$skill"
        $existing = Join-Path $target $item
        if (Test-Path $existing)
        {
            $saved = Join-Path $backup $item
            New-Item -ItemType Directory -Force (Split-Path $saved) | Out-Null
            Move-Item $existing $saved
            Write-Host "Backed up  $item"
        }
        Copy-Item (Join-Path $rossDir $item) $existing -Recurse
        Copy-Item (Join-Path $rossDir "LICENSE") (Join-Path $existing "LICENSE-AMD-ROSS")
        Write-Host "Installed  $item"
    }
    Remove-Item $rossDir -Recurse -Force

    # AMD documentation search MCP server, used by the vendor-docs agent.
    $mcpUrl = "https://ross.amd.com/mcp/doc-search"
    if (Get-Command claude -ErrorAction SilentlyContinue)
    {
        claude mcp add --transport http --scope user amd-doc-search $mcpUrl
    }
    elseif (Get-Command python -ErrorAction SilentlyContinue)
    {
        python (Join-Path $PSScriptRoot "scripts\add_mcp_server.py") amd-doc-search $mcpUrl
    }
    else
    {
        Write-Warning "Add the AMD doc-search MCP server later: claude mcp add --transport http --scope user amd-doc-search $mcpUrl"
    }
}

if (-not $NoGraphify)
{
    Write-Host ""
    Write-Host "Installing graphify (codebase knowledge-graph skill)..."
    try
    {
        if (-not (Get-Command graphify -ErrorAction SilentlyContinue))
        {
            if (Get-Command uv -ErrorAction SilentlyContinue)
            {
                uv tool install graphifyy
            }
            else
            {
                python -m pip install --user graphifyy
            }
        }
        graphify install --platform claude
    }
    catch
    {
        Write-Warning "graphify was not installed: $_"
        Write-Warning "Install it later with:  pip install graphifyy; graphify install --platform claude"
    }
}

Write-Host ""
if (Test-Path $backup)
{
    Write-Host "Previous files saved in $backup"
}
Write-Host "Done. Restart Claude Code so it loads the new agents and skills."
