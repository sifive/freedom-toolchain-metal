# Version number, which should match the official version of the tool we are building
RISCV_TOOLCHAIN_METAL_VERSION := 10.2.0

# Customization ID, which should identify the customization added to the original by SiFive
FREEDOM_TOOLCHAIN_METAL_ID := 2020.12.8

# Characteristic tags, which should be usable for matching up providers and consumers
FREEDOM_TOOLCHAIN_METAL_RISCV_TAGS = rv32i rv64i m a f d c v zfh zba zbb
FREEDOM_TOOLCHAIN_METAL_TOOLS_TAGS = binutils-metal gcc10-metal gdb-metal
