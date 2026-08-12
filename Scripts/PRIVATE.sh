#!/bin/bash

# 用官方 luci-theme-argon (jerrykuku) 覆盖 Packages.sh 中 sbwml 分支的 argon
# 官方 master 的模板不使用 math 模块，可避免 "Unable to resolve path for module 'math'" 报错
# 注意：Packages.sh 先 clone 了 sbwml 的 ./luci-theme-argon，同名目录会导致官方 clone 失败，必须先删
# 另外 UPDATE_PACKAGE 只删 feeds/luci + feeds/packages，扫不到 feeds/base，需手动删 base 下的 argon
rm -rf ./luci-theme-argon
rm -rf ../feeds/base/luci-theme-argon
UPDATE_PACKAGE "argon" "jerrykuku/luci-theme-argon" "master"

UPDATE_PACKAGE "nps-openwrt" "djylb/nps-openwrt" "main" "" "npc nps luci-app-npc luci-app-nps"
UPDATE_PACKAGE "passwall-packages" "Openwrt-Passwall/openwrt-passwall-packages" "main" "name" "xray-core v2ray-geodata sing-box chinadns-ng dns2socks hysteria ipt2socks microsocks naiveproxy shadowsocks-libev shadowsocks-rust shadowsocksr-libev simple-obfs tcping trojan-plus tuic-client v2ray-plugin xray-plugin geoview shadow-tls"
