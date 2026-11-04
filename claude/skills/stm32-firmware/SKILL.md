---
name: stm32-firmware
description: Create, modify or build STM32 firmware and CubeMX/STM32 IDE-generated projects; discover tool bundles and preserve startup, linker and generated-code boundaries. Defaults to bare metal.
---

# STM32 firmware

Enter through the user's clarification/start gate. Read-only discovery is allowed before start; creation, code generation and builds follow the approved plan.

Inspect the exact part, .ioc, IDE/build files, compiler and firmware-package versions. Preserve an existing project's framework and build system. For a new project, default to bare metal and CubeMX/STM32 IDE-generated HAL/LL code with CMake/Ninja where supported. Use an OS only when the user requests it. Clarify HAL/LL/register-level choices when they affect requirements; do not rewrite existing driver style without scope.

Run `scripts/discover_tools.py` for installed bundle paths; `--verify` only checks compiler/CMake/Ninja versions. A tool absent from PATH may be in `%LOCALAPPDATA%/stm32cube/bundles/`. Honor project version pins instead of selecting the newest installed compiler. Discovery does not prove a firmware build or debugger connection works.

For CubeMX changes, inspect the project's .ioc and generator version first. Use the installed CubeMX's documented CLI/batch commands or UI; inspect its help for the actual version rather than inventing generation flags. Preserve USER CODE regions, keep application modules outside generated files where practical, and review the .ioc and generated-source diff. Avoid accidental middleware, clock or pin changes.

Before building, verify device defines, startup/vector table, linker regions, clock assumptions, FPU/ABI and interrupt/peripheral ownership. Read `references/stm32f411.md` only for F411 work. Use exact-device ST datasheet/reference manual/errata; do not copy another family’s registers or cache rules.

Run the project's reproducible CLI build with full logs saved and bounded summaries. Verify ELF/map output, memory usage and warnings. Compile success is not runtime evidence. Host tests exercise portable logic; peripheral behavior needs an authorized hardware check. Use stm32-debug for target operations. No STM32 project or board is currently designated for testing.
