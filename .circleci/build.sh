#!/usr/bin/env bash
# Copyright (C) 2021-2022 Oktapra Amtono <oktapra.amtono@gmail.com>
# Kernel Build Script

# Kernel directory
KERNEL_DIR=$PWD

# Start counting
BUILD_START=$(date +"%s")

# Name and version of kernel
KERNEL_NAME="SUPER.KERNEL"
KERNEL_VERSION=""

# Device name
if [[ "$*" =~ "lavender" ]]; then
    DEVICE="lavender"
    export LOCALVERSION="$KERNEL_VERSION"
elif [[ "$*" =~ "tulip" ]]; then
    DEVICE="tulip"
    export LOCALVERSION="$KERNEL_VERSION"
elif [[ "$*" =~ "whyred" ]]; then
    DEVICE="whyred"
    export LOCALVERSION="$KERNEL_VERSION"
fi

# Blob version
if [[ "$*" =~ "newcam" ]]; then
    CONFIGVERSION="newcam"
elif [[ "$*" =~ "oldcam" ]]; then
    CONFIGVERSION="oldcam"
elif [[ "$*" =~ "tencam" ]]; then
    CONFIGVERSION="tencam"
elif [[ "$*" =~ "qtihaptics" ]]; then
    CONFIGVERSION="qtihaptics"
fi

# Export localversion for OC variant
#if [[ "$*" =~ "oc" ]]; then
#    export LOCALVERSION="$KERNEL_VERSION-overclock"
#fi

# Setup environtment
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="unknown"
export KBUILD_BUILD_HOST="Pancali"
AK3_DIR=$KERNEL_DIR/ak3-$DEVICE
KERNEL_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz
#ZIP_NAME="$KERNEL_NAME"_"$DEVICE""$LOCALVERSION"_"$CONFIGVERSION".zip
ZIP_NAME="$KERNEL_NAME"-"$DEVICE"_"$CONFIGVERSION".zip
ZIP_NAME_ALIAS=Karenul-"$DEVICE"_"$CONFIGVERSION".zip


# Setup toolchain
if [[ "$*" =~ "clang" ]]; then
    CLANG_DIR="$KERNEL_DIR/clang"
    export PATH="$KERNEL_DIR/clang/bin:$PATH"
    CLGV="$("$CLANG_DIR"/bin/clang --version | head -n 1)"
    BINV="$("$CLANG_DIR"/bin/ld --version | head -n 1)"
    LLDV="$("$CLANG_DIR"/bin/ld.lld --version | head -n 1)"
    export KBUILD_COMPILER_STRING="$CLGV - $BINV - $LLDV"
elif [[ "$*" =~ "gcc" ]]; then
    GCC_DIR="$KERNEL_DIR/arm64"
    GCCV="$("$GCC_DIR"/bin/aarch64-elf-gcc --version | head -n 1)"
    BINV="$("$GCC_DIR"/bin/aarch64-elf-ld --version | head -n 1)"
    LLDV="$("$GCC_DIR"/bin/aarch64-elf-ld.lld --version | head -n 1)"
    export KBUILD_COMPILER_STRING="$GCCV - $BINV - $LLDV"
fi

# Export defconfig
make O=out super-"$DEVICE"-"$CONFIGVERSION"_defconfig

# Enable QTI haptics for all build
scripts/config --file out/.config -e CONFIG_INPUT_QTI_HAPTICS

# Start compile
if [[ "$*" =~ "clang" ]]; then
    make -j"$(nproc --all)" O=out \
        CC=clang \
        AR=llvm-ar \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi-
elif [[ "$*" =~ "gcc" ]]; then
    export CROSS_COMPILE="$KERNEL_DIR/arm64/bin/aarch64-elf-"
    export CROSS_COMPILE_ARM32="$KERNEL_DIR/arm32/bin/arm-eabi-"
    make -j"$(nproc --all)" O=out ARCH=arm64
fi

# Make zip
cp -r "$KERNEL_IMG" "$AK3_DIR"/kernel/
cd "$AK3_DIR" || exit
zip -r9 "$ZIP_NAME" ./*

#echo "Zip: $AK3_DIR/$ZIP_NAME_ALIAS"
#curl -T "$AK3_DIR/$ZIP_NAME_ALIAS" temp.sh; echo

#cd "$KERNEL_DIR" || exit
#mkdir kernel-final
#cp "$AK3_DIR"/*.zip kernel-final
#zip -r final.zip kernel-final

cd "$KERNEL_DIR" || exit
cp "$AK3_DIR"/*.zip kernel-done/
curl -T "$AK3_DIR/$ZIP_NAME" https://oshi.at; echo

#echo "Zip: final.zip"
#curl -T final.zip temp.sh; echo

rm -rf out/arch/arm64/boot/
rm -rf out/.version
rm -rf "$AK3_DIR"/*.zip
