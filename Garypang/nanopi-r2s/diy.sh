#!/bin/bash

svn export https://github.com/immortalwrt/immortalwrt/branches/master/package/boot/uboot-rockchip package/boot/uboot-rockchip

find target/linux/rockchip/* -maxdepth 0 ! -path '*/patches-5.10' -exec rm -Rf '{}' \;
svn co https://github.com/immortalwrt/immortalwrt/branches/master/target/linux/rockchip target/linux/rockchip
rm -Rf target/linux/rockchip/.svn
svn co https://github.com/immortalwrt/immortalwrt/branches/master/target/linux/rockchip/patches-5.10 target/linux/rockchip/patches-5.10
rm -Rf target/linux/rockchip/patches-5.10/{006-*-NanoPi-R,007-*-R4S}.patch

rm -rf ./package/kernel/linux/modules/video.mk
wget -P package/kernel/linux/modules/ https://github.com/immortalwrt/immortalwrt/raw/master/package/kernel/linux/modules/video.mk

sed -i 's/5.4/5.10/g' target/linux/rockchip/Makefile

sed -i 's,-mcpu=generic,-march=armv8-a+crypto+crc -mabi=lp64,g' include/target.mk

sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network

sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 8 "ff160000" "ff160000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 1 "ff150000" "ff150000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity

sed -i '/;;/i\ethtool -K eth0 rx off tx off && logger -t disable-offloading "disabed rk3328 ethernet tcp/udp offloading tx/rx"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity

echo '
CONFIG_ARM64_CRYPTO=y
CONFIG_CRYPTO_AES_ARM64=y
CONFIG_CRYPTO_AES_ARM64_BS=y
CONFIG_CRYPTO_AES_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA256_ARM64=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
CONFIG_CRYPTO_SHA512_ARM64=y
CONFIG_CRYPTO_SIMD=y
CONFIG_REALTEK_PHY=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
' >> ./target/linux/rockchip/armv8/config-5.10


