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

The installer copies everything into `~/.claude`. Any file it would replace is first moved to `~/.claude/backups/engineering-setup-<date>`, so nothing is lost. It also installs the [graphify](https://pypi.org/project/graphifyy/) skill from its own package (needs Python or `uv`); skip that with `-NoGraphify` / `--no-graphify`.

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

## Notes

- The Vivado and hardware-debug agents mention AMD skills (`hw-ila-debug`, IP configurator, timing checks, etc.) from AMD's assistant plugin. Those are not included here; the agents work without them.
- MicroBlaze and Zynq platform notes are in [claude/team/platforms/](claude/team/platforms/).
- The `grilling` skill is by Matt Pocock, MIT licensed (see [its LICENSE](claude/skills/grilling/LICENSE)).
