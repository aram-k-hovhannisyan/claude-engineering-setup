# Zynq / Zynq UltraScale+ MPSoC profile

Determine Zynq-7000 versus UltraScale+ MPSoC, exact processor/core, hardware export, tool release and requested bare-metal/RTOS/Linux environment. Do not share startup, boot-image or address-map assumptions across these families.

Trace PS-PL interfaces, DDR/OCM placement, interrupt routing, cache/MMU attributes and DMA buffer ownership. Verify coherent versus noncoherent paths against the actual design; apply cache maintenance only for the relevant memory path.

Use the project's Vitis/PetaLinux/boot-tool versions and official matching manuals. Separate application build, boot packaging, target download and execution evidence. Boot-mode, flash, security configuration, signing/encryption keys and provisioning require explicit task scope; preserve existing material. No HLS or Vitis AI workflow is implied.
