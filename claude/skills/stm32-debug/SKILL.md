---
name: stm32-debug
description: Program or debug an STM32 target with ST-LINK/J-Link, GDB or STM32CubeProgrammer; verify exact target identity, diagnose faults and perform bounded hardware smoke tests.
---

# STM32 target debugging

Operate only within the approved task's hardware scope and assigned session ownership. First match the exact MCU/board, probe type/serial, SWD/JTAG wiring, target voltage and required reset mode. Probe enumeration may be read-only; connect-under-reset, reset, download and programming affect the target and belong in the agreed plan.

Discover project-selected tools and versions. The sibling stm32-firmware skill's `scripts/discover_tools.py` can locate installed ST tool bundles without launching debugger servers. ST-LINK/J-Link extension installation alone does not prove probe drivers or connectivity. Use documented commands/help for the installed CubeProgrammer/GDB-server versions; do not assume executables on PATH or launch multiple owners against one probe.

Match the ELF/map and device memory layout before download. Distinguish load to RAM, ordinary firmware-flash writes, erase, option bytes, readout protection, OTP and provisioning. Security/option-byte/erase-all operations are not implied by ordinary build/debug authorization. Establish whether existing firmware/data must be preserved before destructive operations, rather than promising universal readback/restore.

For a smoke test, define a finite completion signal and timeout, run the code, then verify the signal through memory/register/peripheral evidence. Read numeric CLI results in their documented representation. A download receipt is not execution proof. Breakpoint, stepping and reset tests are separate checks; only claim those exercised.

For faults, capture PC/LR/SP, relevant core fault/status registers and stacked exception state where valid; resolve addresses against the exact ELF/map and part manual. Inspect clocks, interrupt/DMA state and memory bounds relevant to the symptom. Keep diagnostic captures bounded and preserve full logs locally.

Remove temporary breakpoints and restore reversible debug settings where feasible. Report the final processor state, loaded image, flash/data changes and any failed restoration. Do not claim firmware readiness when only the host build was tested. No STM32 board is currently selected.
