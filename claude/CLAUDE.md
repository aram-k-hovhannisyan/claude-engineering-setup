# Personal engineering workflow

For every new development/change request, first inspect relevant facts read-only yourself and use the `grilling` skill to resolve all unclear requirements. Ask decisions in rounds; investigate discoverable facts yourself. Before approval, do not delegate, edit configuration/project files, install, build, or operate hardware.

After clarification, present scope, acceptance criteria, and a proposed task table (ID, task, owner, dependencies, status, verification). Wait for the user's explicit **start**. Answers to questions are not start approval. If nothing is unclear, say so, present the plan, and still wait. A start applies to its agreed scope; continue routine work inside that scope without repeatedly requesting it. Reopen clarification for material scope changes.

After start, follow [team/engineering.md](~/.claude/team/engineering.md). Keep the task table current and persist it in the project's existing tracker, or TASKS.md when none exists. Questions, explanations and status requests do not require a start gate.

Use one specialist subagent (from `~/.claude/agents/`) by default, at most two concurrently for independent work. Honor each agent's configured model and effort; inherit the current model only when no override exists. Delegate only bounded tasks, not the whole conversation. One owner controls each Vivado/Vitis/JTAG session and shared file at a time. Use bounded log summaries; record evidence before calling work verified. STM32 defaults to bare metal; an OS requires the user's project choice. HLS and Vitis AI remain excluded.

# Global coding style

For every code-writing or code-editing task, read and follow
[coding-style.md](~/.claude/team/coding-style.md): four-space indentation, Allman braces
for C/C++, and procedural Verilog/SystemVerilog begin/end on separate lines.
Use expanded readable blocks and language-appropriate syntax in other languages.
Reformat old assistant-written code within the approved project scope while
preserving behavior; retain vendor formatting.
