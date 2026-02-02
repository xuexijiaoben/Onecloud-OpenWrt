#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# 汇总常用插件

function merge_package() {
    # 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    if [[ $# -lt 3 ]]; then
    	echo "Syntax error: [$#] [$*]" >&2
        return 1
    fi
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" target_dir="$3" && shift 3
    rootdir="$PWD"
    localdir="$target_dir"
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    # 使用循环逐个移动文件夹
    for folder in "$@"; do
        mv -f "$folder" "$rootdir/$localdir"
    done
    cd "$rootdir"
}

# 依赖
merge_package master https://github.com/coolsnowwolf/packages package/app multimedia/pppwn-cpp
merge_package openwrt-24.10 https://github.com/immortalwrt/packages package/app net/msd_lite
merge_package main https://github.com/nikkinikki-org/OpenWrt-nikki package/app nikki
merge_package main https://github.com/nikkinikki-org/OpenWrt-nikki package/app luci-app-nikki
merge_package main https://github.com/gdy666/luci-app-lucky package/app lucky
merge_package main https://github.com/gdy666/luci-app-lucky package/app luci-app-lucky
# merge_package main https://github.com/sirpdboy/luci-app-lucky package/app luci-app-lucky
# merge_package main https://github.com/sirpdboy/luci-app-lucky package/app lucky

# 软件包
merge_package main https://github.com/kenzok8/small-package package/app luci-app-adguardhome
merge_package v5 https://github.com/sbwml/luci-app-mosdns package/app luci-app-mosdns mosdns v2dat
merge_package main https://github.com/kenzok8/small-package package/app luci-app-fileassistant
git clone -b js --depth 1 https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/app/luci-app-unblockneteasemusic
git clone -b master https://github.com/sbwml/luci-app-qbittorrent package/app/qbittorrent
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/app/passwall_packages
merge_package main https://github.com/Openwrt-Passwall/openwrt-passwall2 package/app luci-app-passwall2
merge_package main https://github.com/Openwrt-Passwall/openwrt-passwall package/app luci-app-passwall
merge_package dev https://github.com/vernesong/OpenClash package/app luci-app-openclash

merge_package main https://github.com/stackia/rtp2httpd package/app openwrt-support/luci-app-rtp2httpd
merge_package main https://github.com/stackia/rtp2httpd package/app openwrt-support/rtp2httpd

# 内核，参照 kiddin9
shopt -s extglob
SHELL_FOLDER=$(dirname $(readlink -f "$0"))
merge_package main https://github.com/lxiaya/openwrt-onecloud target/linux target/linux/amlogic
sed -i "s/wpad-openssl/wpad-basic-mbedtls/" target/linux/amlogic/image/Makefile
# sed -i "s/neon-vfpv4/vfpv4/" target/linux/amlogic/meson8b/target.mk
rm -rf package/feeds/routing/batman-adv
# 添加无线网卡支持,似乎不起作用？
# sed -i '/bool "Enable SDIO bus interface support"/a\		default y if TARGET_amlogic' package/kernel/mac80211/broadcom.mk

# git clone https://github.com/sbwml/autocore-arm package/autocore-arm -b openwrt-24.10 --depth 1
# rm -rf package/autocore-arm/.git
# sed -i 's/ + '\'' \x27 + luciversion\.revision//g' package/autocore-arm/files/generic/10_system.js

merge_package openwrt-24.10 https://github.com/immortalwrt/immortalwrt package package/emortal/automount

./scripts/feeds update -a

rm -rf feeds/packages/net/microsocks
rm -rf feeds/packages/net/sing-box
rm -rf feeds/packages/net/v2ray-core
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/packages/net/xray-core



merge_package openwrt-23.05 https://github.com/coolsnowwolf/luci feeds/luci/applications applications/luci-app-pppwn
merge_package openwrt-24.10 https://github.com/immortalwrt/luci feeds/luci/applications applications/luci-app-msd_lite

# echo '### Argon Theme Config ###'
# rm -rf feeds/luci/themes/luci-theme-argon
git clone -b master  https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
# rm -rf feeds/luci/applications/luci-app-argon-config # if have
git clone https://github.com/jerrykuku/luci-app-argon-config.git feeds/luci/applications/luci-app-argon-config

./scripts/feeds update -a
./scripts/feeds install -a
