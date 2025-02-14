#!/bin/bash

DEFCONFIG="S88503AC1-perf_defconfig"

make -j"$(nproc --all)" O=out ARCH=arm64 SUBARCH=arm64 "$DEFCONFIG"
cp -af out/.config arch/arm64/configs/"$DEFCONFIG"
git add arch/arm64/configs/"${DEFCONFIG}"
git commit -m "Arm64: Configs: Defconfig: Regenerate"
echo -e "\nSuccessfully regenerated defconfig at $DEFCONFIG"
