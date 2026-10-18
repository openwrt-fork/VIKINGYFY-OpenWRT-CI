#!/bin/bash

# 用官方 luci-theme-argon (jerrykuku) 覆盖 Packages.sh 中 sbwml 分支的 argon
# 官方 master 的主题声明了 ucode-mod-math 依赖，可避免 "Unable to resolve path for module 'math'" 报错
# 注意：Packages.sh 已先把 sbwml 仓库 clone 到 ./package/luci-theme-argon（含 theme 与 app-config），
# 同名目录会导致官方 clone 失败（fatal: destination path ... already exists），必须先删；
# 该仓库被删后 app-config 也会消失，故用官方 luci-app-argon-config 补齐。
rm -rf ./package/luci-theme-argon
UPDATE_PACKAGE "argon-config" "jerrykuku/luci-app-argon-config" "master"
UPDATE_PACKAGE "argon" "jerrykuku/luci-theme-argon" "master"

# feeds/packages 中 miniupnpd 的旧补丁与 2.3.11 源码不匹配：
# immortalwrt/packages 于 2026-10-16 合并官方源后升级到 2.3.11，但未同步整理本地补丁，
# 导致 patch 应用失败（Patch failed! ... 020-descr-filter-fix.patch）。
# - 020/030 的改动已合入 2.3.11 源码，重复应用会报 reversed
# - 040 只调整日志级别与帮助文案，2.3.11 改了相关上下文导致 4 个 hunk 失败，移除不影响功能
# 010/900 仍可正常应用，保留。
rm -f ./feeds/packages/net/miniupnpd/patches/020-descr-filter-fix.patch
rm -f ./feeds/packages/net/miniupnpd/patches/030-allow-private-fix.patch
rm -f ./feeds/packages/net/miniupnpd/patches/040-improve-logging.patch

UPDATE_PACKAGE "nps-openwrt" "djylb/nps-openwrt" "main" "" "npc nps luci-app-npc luci-app-nps"
UPDATE_PACKAGE "passwall-packages" "Openwrt-Passwall/openwrt-passwall-packages" "main" "name" "xray-core v2ray-geodata sing-box chinadns-ng dns2socks hysteria ipt2socks microsocks naiveproxy shadowsocks-libev shadowsocks-rust shadowsocksr-libev simple-obfs tcping trojan-plus tuic-client v2ray-plugin xray-plugin geoview shadow-tls"
