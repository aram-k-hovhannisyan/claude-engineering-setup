# Installs the engineering team setup into ~/.claude (Windows PowerShell 5.1+).
# Usage:  powershell -ExecutionPolicy Bypass -File install.ps1 [-NoGraphify]

param(
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
