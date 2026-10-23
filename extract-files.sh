#!/bin/bash
#
# Pull the proprietary files listed in proprietary-blobs.txt.
#
#   ./extract-files.sh                 # from the device over adb
#   ./extract-files.sh -d <dump_dir>   # from an unpacked ROM's system/ tree
#
# Paths in the list are relative to /system.  A line may be written as
# "src:dst" to install the file under a different name.
#
set -e

# Everything is copied under vendor/<vendor>/<device>/proprietary.
DEVICE=aries
VENDOR=xiaomi
VENDOR_DIR=../../../vendor/$VENDOR/$DEVICE
PROPRIETARY=$VENDOR_DIR/proprietary

BASE=$(dirname "$0")
cd "$BASE"

SRC=adb
DUMP_DIR=

while getopts "d:" opt; do
    case "$opt" in
        d) DUMP_DIR="$OPTARG"; SRC=dump ;;
        *) echo "usage: $0 [-d <dump_dir>]" >&2; exit 1 ;;
    esac
done

if [ "$SRC" = "dump" ] && [ ! -d "$DUMP_DIR" ]; then
    echo "error: '$DUMP_DIR' is not a directory" >&2
    exit 1
fi

mkdir -p "$PROPRIETARY"

# Copy one file from the connected device.
pull_adb() {
    local src="$1" dst="$2"
    mkdir -p "$PROPRIETARY/$(dirname "$dst")"
    adb pull "/system/$src" "$PROPRIETARY/$dst" >/dev/null 2>&1
}

# Copy one file from the unpacked tree.
pull_dump() {
    local src="$1" dst="$2"
    if [ -f "$DUMP_DIR/$src" ]; then
        mkdir -p "$PROPRIETARY/$(dirname "$dst")"
        cp -f "$DUMP_DIR/$src" "$PROPRIETARY/$dst"
        return 0
    fi
    return 1
}

pull() {
    if [ "$SRC" = "adb" ]; then
        pull_adb "$@"
    else
        pull_dump "$@"
    fi
}

OK=0
MISS=0

while read -r line; do
    # Skip blank lines and comments.
    case "$line" in
        ''|'#'*) continue ;;
    esac

    # "src:dst" installs under a different name; a plain path keeps it.
    src="${line%%:*}"
    if [ "$src" = "$line" ]; then
        dst="$line"
    else
        dst="${line#*:}"
    fi

    printf '  %-56s ' "$src"
    if pull "$src" "$dst"; then
        echo "ok"
        OK=$((OK + 1))
    else
        echo "MISSING"
        MISS=$((MISS + 1))
    fi
done < proprietary-blobs.txt

echo
echo "extracted: $OK, missing: $MISS"

if [ "$OK" -eq 0 ]; then
    echo "error: nothing was extracted, aborting" >&2
    exit 1
fi

# Regenerate the vendor makefiles from what was extracted.
./setup-makefiles.sh
