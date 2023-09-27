#!/usr/bin/env bash
echo "Cloning dependencies"
git clone https://github.com/najahiiii/aarch64-linux-gnu.git -b 4.9-mirror --depth=1 gcc
git clone https://github.com/dndxtz/AnyKernel3 -b miui --depth=1 AnyKernel
echo "Done"

chat_id=-1001944300223
token=728234533:AAHgxu6Y_PsExZNJoYiDgC74K_J-Ok0OaUk

ZIP_NAME="IdkSerKernel-MIUI-Rolex-${tanggal}.zip"
KERNEL_DIR=$(pwd)
TC=$(pwd)/gcc/bin/aarch64-linux-android-
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
tanggal=$(TZ=Asia/Jakarta date "+%Y%m%d-%H%M")
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
export ARCH=arm64
export KBUILD_BUILD_USER=dndxtz
export KBUILD_BUILD_HOST=DESKTOP-ET3IKPU
export PATH="${PATH}:$(pwd)/gcc/bin"
git config --global user.email "dindascape@gmail.com"
git config --global user.name "dndxtz"

# Push kernel to channel
function push() {
    cd AnyKernel
    curl -F document=@$ZIP_NAME "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
	-F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)."
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Job Baking Chips throw an error(s)"
    exit 1
}

# Env
ZIP_DIR=$KERNEL_DIR/AnyKernel
VENDOR_MODULEDIR="$ZIP_DIR/modules/system/lib/modules"
STRIP="aarch64-linux-android-strip"

# Do Wifi modules
function wifi_modules() {
    # credit @adekmaulana
    for MODULES in $(find "$KERNEL_DIR/out" -name '*.ko'); do
        "${STRIP}" --strip-unneeded --strip-debug "${MODULES}"
        "$KERNEL_DIR/scripts/sign-file" sha512 \
                "$KERNEL_DIR/out/signing_key.priv" \
                "$KERNEL_DIR/out/signing_key.x509" \
                "${MODULES}"
        case ${MODULES} in
                */wlan.ko)
            cp "${MODULES}" "${VENDOR_MODULEDIR}/wlan.ko" ;;
        esac
    done
    echo -e "(i) Done moving wifi modules"
}
# Compile plox
function compile() {
    make -s -C "$(pwd)" -j"$(nproc)" O=out S88503AC1-perf_defconfig
    make -C $(pwd) CROSS_COMPILE="${TC}" O=out -j8
        if ! [ -a "$IMAGE" ]; then
            finerr
            exit 1
        fi
    wifi_modules
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel/
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 $ZIP_NAME *
    cd ..
}

compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
