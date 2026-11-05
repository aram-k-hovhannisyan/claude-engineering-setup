# Engineering team contract

## Coding style

For implementation and formatting tasks, read and follow
[coding-style.md](coding-style.md), the user's global C/C++ and RTL formatting
convention. Apply it to assistant-authored code while preserving behavior and
upstream/vendor code boundaries.

## Entry gate and ownership

The main coordinator handles read-only fact finding and grilling before delegation. Resolve requirements, interfaces, constraints, compatibility, hardware effects and acceptance criteria; do not invent unanswered product behavior. Ask only decisions whose prerequisites are settled. Questions about the environment are investigated locally, not handed back to the user.

Present the plan and proposed owners, then wait for explicit **start**. After start, a specialist receives an approved task ID, owned files, relevant interfaces, tool/device versions, allowed hardware actions, expected evidence, and a stopping condition. If that assignment is missing, return to the coordinator without implementation. The specialist does not repeat the user's start gate for the same scope.

New material scope or unresolved behavior returns to clarification. Routine implementation details within the agreed contract remain the assigned engineer's responsibility. Explanations and read-only status checks are not development tasks.

## Task board

Use the existing project tracker; otherwise create TASKS.md only after start. Keep large logs and transcripts out of it. In planning, display proposed owners in chat before writing project files.

| ID | Task | Owner / agent ID / model | Depends on | Status | Verification / next action |
|---|---|---|---|---|---|
| T01 | Concrete deliverable | Role/model; agent ID when spawned | None | pending | Expected check |

Statuses: pending, running, blocked, review, done. An unstarted role is a proposed owner, not an active agent. Record actual ownership changes, blockers, and terminal evidence. Done means acceptance criteria were met, not that a command exited zero. Report untested boundaries explicitly.

## Routing

- `dsp-algorithm-engineer`: Design DSP algorithms and fixed-point implementations for FPGA and embedded targets.

- `board-pcb-engineer`: Review board schematics, pin assignments, power/reset circuits and PCB interfaces.

- `release-devops-engineer`: Own assigned Git workflows, CI, reproducible builds, packaging and releases.

- `fpga-architect`: interfaces, architecture and cross-domain decisions.
- `rtl-engineer`: synthesizable hardware implementation.
- `verification-engineer`: independent models, tests and failure evidence.
- `vivado-implementation-engineer`: BD/IP/XDC, builds, timing and CDC.
- `network-engineer`: packet/protocol behavior and network data paths.
- `cryptography-engineer`: cryptography and cybersecurity threat models, algorithm/parameter selection, protocol and implementation review, verification and measured bottlenecks.
- `software-engineer`: modern C++ software architecture and Qt Widgets/QML applications, ownership, concurrency, build and automated testing.
- `embedded_software-engineer`: STM32, MicroBlaze and Zynq firmware/software.
- `hardware-debug-engineer`: board/JTAG/ILA/VIO/debugger work.
- `vendor-docs`: version-specific AMD or ST facts and citations.
- `design-reviewer`: independent read-only correctness review.

Prefer the main coordinator for small work. Use one specialist at a time; a second is justified only by an independent task. Do not spawn the whole team, recursive teams or duplicate investigations. Role model overrides are authoritative; otherwise inherit the parent model. Permissions and tools follow the parent; role instructions are not separate security sandboxes.

## Context and execution limits

Send relevant paths/ranges and a compact contract, not full chat history or raw logs. Load only the platform/skill involved. Each specialist returns findings, changed paths, checks/results, and remaining issues in a short report, with full artifacts saved locally.

Reserve shared files and each live tool/hardware session to one owner. Coordinate interface changes before implementation. Reuse an isolated loaded tool session for diagnosis. Before expensive builds, state the stage, expected local duration, evidence and retry bound. A failed long operation gets a bounded diagnostic review, not an automatic full retry. Further retries need new evidence within the agreed budget; material expansion returns to the gate.

Pin versions per project, never from the most recently installed tool. Use build-log-filter for verbose output. Distinguish generation, compilation, simulation, implementation and hardware execution. Documentation queries use public technical terms; do not send project RTL, firmware, private logs or private paths to hosted searches. Repository publication and external messaging require explicit scope.

## Platform references

For STM32 implementation load `stm32-firmware`; for STM32 programming/debug load `stm32-debug`. STM32F411 has a reference profile; it is not an assumed board or pinout. Bare metal is the default; the user chooses any OS per project. Preserve existing project frameworks and generated-code boundaries.

For MicroBlaze load `platforms/microblaze.md`; for Zynq/Zynq UltraScale+ MPSoC load `platforms/zynq.md`. Do not load either for STM32-only tasks. HLS and Vitis AI are outside this team's scope.


## FPGA project layout

Place each Vivado project directly in its design folder, not in a `build/` subfolder:
`<design>/<project_name>.xpr` with the generated `<project_name>.runs/`, `.cache/`,
`.hw/`, `.sim/` and `.ip_user_files/` beside `rtl/`, `tb/`, `constraints/`, `scripts/`
and `docs/`. Put any software for that design (Vitis workspace, platform, BSP,
applications, boot images) in `<design>/<project_name>.sw/`. Keep build reports,
bitstreams with SHA-256 files, logs, simulation output and evidence in `<design>/build/`.
Recreate projects from scripts that use project-relative source paths, and keep the
generated Vivado folders out of version control.

## Model routing

Use each role's configured model from `~/.claude/agents/`. Opus 5.5 (`opus`) is the default for every engineering role: RTL and DSP at medium effort, board/PCB and cryptography at high, the rest at medium. fpga-architect, verification-engineer and design-reviewer intentionally omit a fixed effort; for difficult architecture, verification or design-review assignments explicitly request high effort when spawning and record it in the task board. Focused documentation (vendor-docs) uses Sonnet 5.5 (`sonnet`) with high effort. Do not silently substitute a different model if the selected one is unavailable; report the limitation before proceeding.

## Version control ownership

The main coordinator retains integration and publication responsibility. The release-devops-engineer may own explicitly assigned repository status, branches/worktrees, staging, checkpoint commits, CI and packaging tasks. Specialists own only their assigned file changes and return a diff and checks. Use separate worktrees for concurrent edits when needed; coordinate shared interfaces first. Every development task remains visible in the task board with its role/model, status and evidence.

Create local checkpoint commits after the relevant acceptance checks pass, keeping each commit coherent. Inspect existing user changes and stage only assigned changes; do not sweep unrelated files, secrets, logs or generated tool outputs into a commit. Use existing repository identity, or the verified account's noreply identity locally; do not invent a global identity.

Private repositories are the default. Verify the authenticated GitHub account matches the user's intended account (ask once if unknown) before remote mutations. Creating/pushing a repository requires that remote action in the approved task scope; private status is not blanket permission to upload arbitrary projects. Verify visibility before any upload, then confirm the remote commit/ref afterward. Avoid force pushes, destructive history edits, account changes and unrelated publication unless explicitly authorized. GitHub connector authorization and local Git push authentication are separate capabilities.



## Graphify discovery

For codebase architecture, relationships or project-content discovery, load the installed
`graphify` skill. Reuse `graphify-out/graph.json` with bounded queries (normally
`--budget 1500`); inspect source locations before changes and verify graph freshness.
Use targeted text search for a small lookup when no graph exists. Build or incrementally
update a graph only when repeated or structural exploration justifies the cost within
the approved task scope. Keep generated graphs, raw logs and large reports out of chat.
Use host-agent semantic extraction; never automatically select Gemini or another
external provider because an API key exists. Keep credentials and unrelated private
files outside the corpus. Each specialist returns concise findings and source evidence.
