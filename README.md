# Claude Code engineering team setup

A ready-made [Claude Code](https://claude.com/claude-code) setup for embedded, FPGA and systems engineering work: a global workflow, 14 specialist subagents, and the skills they rely on.

## Install

You need Claude Code installed. Then:

```
git clone https://github.com/aram-k-hovhannisyan/claude-engineering-setup.git
cd claude-engineering-setup
```

**Windows (PowerShell)**

```
powershell -ExecutionPolicy Bypass -File install.ps1
```

**macOS / Linux / Git Bash**

```
./install.sh
```

Restart Claude Code afterwards.

The installer copies everything into `~/.claude`. Any file it would replace is first moved to `~/.claude/backups/engineering-setup-<date>`, so nothing is lost. It also:

- Downloads the [AMD Ross Agentic AI Assistant](https://github.com/Xilinx/ross-ai-assistant) at a pinned commit and installs **only the 16 skills listed in [ross-skills.txt](ross-skills.txt)** (Vivado, ILA/VIO, segmented configuration, Vitis embedded). HLS and Vitis AI skills are left out. It also registers AMD's `amd-doc-search` documentation MCP server (uses Python to edit `~/.claude.json` when the `claude` CLI is not on PATH; a backup is saved next to it). Skip with `-NoRoss` / `--no-ross`.
- Installs the [graphify](https://pypi.org/project/graphifyy/) skill from its own package (needs Python or `uv`). Skip with `-NoGraphify` / `--no-graphify`.

To install a different set of AMD skills, edit `ross-skills.txt` before running the installer.

To update later: `git pull`, then run the installer again.

## What you get

**Workflow** ([claude/CLAUDE.md](claude/CLAUDE.md))

- For every change request, Claude first investigates read-only and asks clarifying questions in rounds (using the `grilling` skill).
- It then shows the scope, acceptance criteria and a task table, and **waits for you to type `start`** before editing, building, installing or touching hardware.
- Work is tracked in the project's tracker, or `TASKS.md`.
- Coding style: 4-space indents, Allman braces for C/C++, `begin`/`end` on their own lines in Verilog ([claude/team/coding-style.md](claude/team/coding-style.md)).

The full team contract is in [claude/team/engineering.md](claude/team/engineering.md).

**Subagents** ([claude/agents/](claude/agents/))

| Agent | Model | Effort |
|---|---|---|
| embedded-software-engineer | Opus | medium |
| hardware-debug-engineer | Opus | medium |
| rtl-engineer | Opus | medium |
| dsp-algorithm-engineer | Opus | medium |
| vivado-implementation-engineer | Opus | medium |
| network-engineer | Opus | medium |
| software-engineer | Opus | medium |
| release-devops-engineer | Opus | medium |
| board-pcb-engineer | Opus | high |
| cryptography-engineer | Opus | high |
| fpga-architect | Opus | chosen per task |
| verification-engineer | Opus | chosen per task |
| design-reviewer (read-only) | Opus | chosen per task |
| vendor-docs (read-only) | Sonnet | high |

To change a model, edit the `model:` line at the top of the agent's file (`opus`, `sonnet`, `haiku`, `fable`, or a full model ID).

**Skills** ([claude/skills/](claude/skills/))

| Skill | Purpose |
|---|---|
| stm32-firmware | Create/build STM32 firmware and CubeMX projects (bare metal by default) |
| stm32-debug | Program and debug STM32 targets via ST-LINK/J-Link, GDB, CubeProgrammer |
| build-log-filter | Save long build logs to disk and extract only the useful errors |
| grilling | Structured clarifying questions before work starts |
| graphify | Codebase knowledge graph (installed by the installer from its own package) |
| AMD Ross (16) | `hw-ila-debug`, `hw-vio-debug`, `vitis-embedded`, `vivado-ip-configurator`, `vivado-revision-control`, `vivado-rtl-elaboration-analysis`, `vivado-rtl-lint`, `vivado-simulate-rtl`, `vivado-timing-methodology-checks`, and 7 `segcfg-*` skills |

## Notes

- Several AMD Ross skills drive Vivado through AMD's **Vivado MCP server**, which is a separate download from the [AMD Ross page](https://www.amd.com/en/support/downloads/ross-agentic-ai.html) and is not installed by this repo.
- AMD Ross skills are © Advanced Micro Devices, Inc., MIT licensed; each installed skill gets a `LICENSE-AMD-ROSS` copy.
- MicroBlaze and Zynq platform notes are in [claude/team/platforms/](claude/team/platforms/).
- The `grilling` skill is by Matt Pocock, MIT licensed (see [its LICENSE](claude/skills/grilling/LICENSE)).
