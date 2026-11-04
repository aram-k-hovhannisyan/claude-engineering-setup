# MicroBlaze profile

Read the project's XSA, BSP/domain, linker map and tool version before choosing commands. Use native XSCT for 2021.1 projects; do not apply Unified Vitis Python APIs to them. Keep software tied to the producing hardware export and record version/artifact hashes.

Check memory ranges, reset/exception vectors, interrupt controller, cache regions and DMA coherency against the actual hardware. Do not assume a UART exists. A small RAM result signature can verify a UART-free smoke program when hardware execution is authorized.

Select the exact JTAG cable/device and processor; distinguish the application's MicroBlaze from calibration/debug subsystem processors. ELF compilation is not execution evidence. Read back a changed signature after running and report whether the CPU was left running, halted, reset or reprogrammed. Use the authorized session owner for hardware actions.
