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

# Product definition for the Xiaomi MI 2 (aries).
#
# device.mk must be inherited before full.mk; the PRODUCT_* values of both are
# concatenated.

$(call inherit-product, device/xiaomi/aries/device.mk)
$(call inherit-product, build/target/product/languages_full.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full.mk)

# Blobs generated from vendor/xiaomi/aries by extract-files.sh.
$(call inherit-product-if-exists, vendor/xiaomi/aries/aries-vendor.mk)

PRODUCT_NAME         := full_aries
PRODUCT_DEVICE       := aries
PRODUCT_BRAND        := Xiaomi
PRODUCT_MODEL        := MI 2
PRODUCT_MANUFACTURER := Xiaomi

# The 320 dpi screen uses hdpi resources; the density entry has to come after
# all inherits so that it stays at the end of PRODUCT_LOCALES.
PRODUCT_LOCALES      += hdpi
