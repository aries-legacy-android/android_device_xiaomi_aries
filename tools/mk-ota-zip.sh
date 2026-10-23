#!/bin/bash
#
# Build a recovery-flashable zip from out/target/product/aries.
#
#   ./tools/mk-ota-zip.sh [-o <zip>] [-s] [--no-assert]
#
set -eu

DEVICE=aries
BASE=$(cd "$(dirname "$0")" && pwd)
TOP=$(cd "$BASE/../../../.." && pwd)
OUT=${OUT:-$TOP/out/target/product/$DEVICE}

ZIP=$OUT/aosp-2.3.7-$DEVICE-$(date +%Y%m%d).zip
SIGN=0
ASSERT=1

die() { echo "error: $*" >&2; exit 1; }

while [ $# -gt 0 ]; do
    case $1 in
        -o) ZIP=${2:?missing argument}; shift 2 ;;
        -s) SIGN=1; shift ;;
        --no-assert) ASSERT=0; shift ;;
        *) die "usage: $0 [-o <zip>] [-s] [--no-assert]" ;;
    esac
done

[ -f "$BASE/updater" ] || die "tools/updater not found"
[ -f "$OUT/boot.img" ] || die "$OUT/boot.img not found"
[ -f "$OUT/system.img" ] || die "$OUT/system.img not found"
command -v zip >/dev/null || die "zip not installed"

WORK=$OUT/ota-zip
rm -rf "$WORK"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/META-INF/com/google/android"

cp "$OUT/boot.img" "$WORK/boot.img"

# The device build produces sparse ext4 images; flash the expanded data.
if [ "$(od -An -tx1 -N4 "$OUT/system.img" | tr -d ' \n')" = "3aff26ed" ]; then
    SIMG2IMG=$TOP/out/host/linux-x86/bin/simg2img
    [ -x "$SIMG2IMG" ] || SIMG2IMG=$(command -v simg2img || true)
    [ -n "$SIMG2IMG" ] || die "simg2img not found"
    echo "expanding system.img"
    "$SIMG2IMG" "$OUT/system.img" "$WORK/system.img"
else
    cp "$OUT/system.img" "$WORK/system.img"
fi

install -m 755 "$BASE/updater" "$WORK/META-INF/com/google/android/update-binary"

{
    [ "$ASSERT" -eq 1 ] && echo "assert(getprop(\"ro.product.device\") == \"$DEVICE\" || getprop(\"ro.build.product\") == \"$DEVICE\");"
    cat <<'EOF'
ui_print("aries: unmounting system");
unmount("/system");
ui_print("aries: writing boot");
package_extract_file("boot.img", "/dev/block/platform/msm_sdcc.1/by-name/boot");
ui_print("aries: writing system");
show_progress(0.5, 40);
package_extract_file("system.img", "/dev/block/platform/msm_sdcc.1/by-name/system");
show_progress(1.0, 0);
ui_print("aries: done, wipe data if coming from another ROM");
EOF
} > "$WORK/META-INF/com/google/android/updater-script"

echo "packing $(basename "$ZIP")"
rm -f "$ZIP"
(cd "$WORK" && zip -rq "$ZIP" .)

if [ "$SIGN" -eq 1 ]; then
    JAR=$TOP/out/host/linux-x86/framework/signapk.jar
    KEY=$TOP/build/target/product/security/testkey
    [ -f "$JAR" ] || die "signapk.jar not found, run make signapk"
    java -jar "$JAR" -w "$KEY.x509.pem" "$KEY.pk8" "$ZIP" "$ZIP.signed"
    mv "$ZIP.signed" "$ZIP"
fi

echo "done: $ZIP ($(du -h "$ZIP" | cut -f1))"
