# Version number, which should match the official version of the tool we are building
RISCV_TOOLCHAIN_METAL_VERSION := dev

# Customization ID, which should identify the customization added to the original by SiFive
FREEDOM_TOOLCHAIN_METAL_ID := $(shell cd ../freedom-gcc-metal/src/riscv-gcc/ && git log --pretty=format:'%h' -1)$(shell cd ../freedom-gcc-metal/src/riscv-newlib/ && git log --pretty=format:'-%h' -1)$(shell cd ../freedom-binutils-metal/src/riscv-binutils/ && git log --pretty=format:'-%h' -1)

# Characteristic tags, which should be usable for matching up providers and consumers
FREEDOM_TOOLCHAIN_METAL_RISCV_TAGS = rv32i rv64i m a f d c v zfh zba zbb
FREEDOM_TOOLCHAIN_METAL_TOOLS_TAGS = binutils-metal gcc-metal gdb-metal
