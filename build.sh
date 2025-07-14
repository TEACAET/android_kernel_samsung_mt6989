#!/bin/bash

set -e

# download toolchain from https://opensource.samsung.com/uploadSearch?searchValue=toolchain 
TOOLCHAIN=$(realpath "/home/teacaet/桌面/KERNEL/toolchain/prebuilts")

export PATH=$TOOLCHAIN/build-tools/linux-x86/bin:$PATH
export PATH=$TOOLCHAIN/build-tools/path/linux-x86:$PATH
export PATH=$TOOLCHAIN/clang/host/linux-x86/clang-r487747c/bin:$PATH

echo $PATH

TARGET_DEFCONFIG=${1:-mt6989_defconfig}

cd "$(dirname "$0")"


LOCALVERSION=-android14-TEACAET

ARGS="
CC=clang
ARCH=arm64
LLVM=1 LLVM_IAS=1
LOCALVERSION=$LOCALVERSION
"

# build kernel
make -j$(nproc) -C $(pwd) O=$(pwd)/out ${ARGS} $TARGET_DEFCONFIG

./scripts/config --file out/.config \
  -d UH \
  -d RKP \
  -d KDP \
  -d SECURITY_DEFEX \
  -d INTEGRITY \
  -d FIVE \
  -d TRIM_UNUSED_KSYMS

make -j$(nproc) -C $(pwd) O=$(pwd)/out ${ARGS}

cd out
if [ ! -d AnyKernel3 ]; then
  git clone --depth=1 https://github.com/YuzakiKokuban/AnyKernel3.git -b mt6989
fi
 cp arch/arm64/boot/Image AnyKernel3/zImage
 name=${TARGET_DEFCONFIG%%_defconfig}_kernel_`cat include/config/kernel.release`_`date '+%Y_%m_%d'`
 cd AnyKernel3
 zip -r ${name}.zip * -x *.zip
 echo "AnyKernel3 package output to $(realpath $name).zip"
