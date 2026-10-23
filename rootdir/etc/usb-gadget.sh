#!/system/bin/sh
#
# USB gadget setup for aries (Android 2.3).
#
# There is no UsbDeviceManager in 2.3, so nothing translates
# persist.sys.usb.config into the gadget sysfs.  Without this the controller
# stays disabled and the host sees no device at all.  adb only for now.

G=/sys/class/android_usb/android0
FUNCTIONS=adb

log() {
    echo "usb-gadget: $*" > /dev/kmsg
}

# Write a gadget attribute and log the value read back.
set_attr() {
    echo "$2" > "$G/$1" 2>/dev/null
    log "$1=$(cat "$G/$1" 2>/dev/null)"
}

# Disable first; the write also checks that the gadget exists.
echo 0 > $G/enable 2>/dev/null || { log "missing $G"; exit 1; }

set_attr idVendor 0x18D1
set_attr idProduct 0x4E11
set_attr iSerial "$(getprop ro.serialno)"
set_attr iManufacturer Xiaomi
set_attr iProduct "MI 2"
set_attr functions "$FUNCTIONS"

echo 1 > $G/enable 2>/dev/null
log "enable=$(cat $G/enable 2>/dev/null) state=$(cat $G/state 2>/dev/null)"

# Binding the function resets the descriptor strings, so write them again.
set_attr iSerial "$(getprop ro.serialno)"
set_attr iManufacturer Xiaomi
set_attr iProduct "MI 2"

setprop sys.usb.config "$FUNCTIONS"
setprop sys.usb.state "$FUNCTIONS"

log "adb node: $(ls -l /dev/android_adb 2>&1)"
