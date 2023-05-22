#!/usr/bin/env bash
# Copyright (C) 2020-2022 Oktapra Amtono <oktapra.amtono@gmail.com>
# Docker Kernel Build Script

# Print cpu cores
CORES=$(grep -c ^processor /proc/cpuinfo)
CPU=$(lscpu | sed -nr '/Model name/ s/.*:\s*(.*) */\1/p')

# Toolchain setup
if [[ "$*" =~ "clang" ]]; then
    CLANG_DIR="clang"
    CLGV="$("$CLANG_DIR"/bin/clang --version | head -n 1)"
    BINV="$("$CLANG_DIR"/bin/ld --version | head -n 1)"
    LLDV="$("$CLANG_DIR"/bin/ld.lld --version | head -n 1)"
    KBUILD_COMPILER_STRING="$CLGV - $BINV - $LLDV"
elif [[ "$*" =~ "gcc" ]]; then
    GCC_DIR="arm64"
    GCCV="$("$GCC_DIR"/bin/aarch64-elf-gcc --version | head -n 1)"
    BINV="$("$GCC_DIR"/bin/aarch64-elf-ld --version | head -n 1)"
    LLDV="$("$GCC_DIR"/bin/aarch64-elf-ld.lld --version | head -n 1)"
    KBUILD_COMPILER_STRING="$GCCV - $BINV - $LLDV"
fi
