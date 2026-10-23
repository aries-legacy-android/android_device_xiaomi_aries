#
# Copyright (C) 2012 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Xiaomi MI 2 (aries): APQ8064, 2 GB RAM, 4.3" 1280x720, no external SD card.

TARGET_ARCH                  := arm
TARGET_ARCH_VARIANT          := armv7-a-neon
TARGET_ARCH_VARIANT_CPU      := cortex-a9
TARGET_CPU_ABI               := armeabi-v7a
TARGET_CPU_ABI2              := armeabi
TARGET_CPU_SMP               := true
ARCH_ARM_HAVE_TLS_REGISTER   := true

TARGET_BOARD_PLATFORM        := msm8960
TARGET_BOOTLOADER_BOARD_NAME := MSM8960
TARGET_NO_KERNEL             := false

TARGET_GLOBAL_CFLAGS         += -mfpu=neon -mfloat-abi=softfp -DQCOM_HARDWARE
TARGET_GLOBAL_CPPFLAGS       += -mfpu=neon -mfloat-abi=softfp -DQCOM_HARDWARE
COMMON_GLOBAL_CFLAGS         += -D__ARM_USE_PLD -D__ARM_CACHE_LINE_SIZE=64

# Boot image, values taken from the factory boot.img.
BOARD_KERNEL_BASE            := 0x80200000
BOARD_KERNEL_PAGESIZE        := 2048
BOARD_FORCE_RAMDISK_ADDRESS  := 0x82200000
BOARD_KERNEL_CMDLINE         := console=null androidboot.hardware=qcom ehci-hcd.park=3 androidboot.bootdevice=msm_sdcc.1

TARGET_KERNEL_SOURCE         := kernel/xiaomi/aries
KERNEL_DEFCONFIG             ?= aries-perf-user_defconfig

# Partition sizes from the MIUI V9 GPT.
TARGET_USERIMAGES_USE_EXT4         := true
BOARD_BOOTIMAGE_PARTITION_SIZE     := 31457280
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 1073741824
BOARD_USERDATAIMAGE_PARTITION_SIZE := 1073741824
BOARD_FLASH_BLOCK_SIZE             := 131072

# Software rendering only.
BOARD_EGL_CFG                := device/xiaomi/aries/rootdir/etc/egl.cfg
USE_OPENGL_RENDERER          := true

# Prelink uses fixed addresses that conflict with the runtime mappings.
TARGET_PRELINK_MODULE        := false

# No camera HAL and no audio HAL yet.
USE_CAMERA_STUB              := true
BOARD_USES_GENERIC_AUDIO     := true

TARGET_NO_RECOVERY           := true

BOARD_HAVE_BLUETOOTH         := true

-include vendor/xiaomi/aries/BoardConfigVendor.mk
