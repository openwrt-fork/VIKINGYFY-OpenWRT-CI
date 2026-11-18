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

# djylb/nps-openwrt 的版号与哈希由上游自动化写入，但 2026-11-16 那次更新写坏成了 null
# （PKG_VERSION:=null、哈希全为占位值），会去下载 .../releases/download/vnull/... 全部 404，
# 导致 package/nps-openwrt/npc 编译失败。这里按 djylb/nps 最新的正式 release
# 重写 PKG_VERSION 和各架构哈希；上游修复后本段仍会写入同样的正确值，可长期保留。
_fix_nps_openwrt() {
	local RELEASE VER ASSETS FILE KIND ARCH HASH SPEC
	if ! RELEASE=$(gh api repos/djylb/nps/releases/latest --jq .tag_name); then
		echo "nps-openwrt 修复失败：无法获取 djylb/nps 最新 release"
		return 1
	fi
	VER=${RELEASE#v}
	if ! ASSETS=$(gh api "repos/djylb/nps/releases/tags/$RELEASE" --jq '.assets[] | "\(.name) \(.digest)"'); then
		echo "nps-openwrt 修复失败：无法获取 $RELEASE 的资源列表"
		return 1
	fi

	for SPEC in "npc:client" "nps:server"; do
		FILE="./package/nps-openwrt/${SPEC%%:*}/Makefile"
		KIND=${SPEC##*:}
		[ -f "$FILE" ] || continue

		sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=$VER/" "$FILE"
		for ARCH in amd64 386 arm64 arm_v7 arm_v6 arm_v5 mips_softfloat mipsle_softfloat mips64 mips64le loong64 riscv64; do
			HASH=$(awk -v name="linux_${ARCH}_${KIND}.tar.gz" '$1 == name { sub(/^sha256:/, "", $2); print $2 }' <<< "$ASSETS")
			[ -n "$HASH" ] || continue
			# 只替换哈希值，保留行尾的续行符（最后一项没有）
			sed -i "s|^\(  ${ARCH}=\)[^ ]*|\1${HASH}|" "$FILE"
		done
		echo "nps-openwrt: ${SPEC%%:*} 已修正为 $RELEASE"
	done
}
_fix_nps_openwrt

UPDATE_PACKAGE "passwall-packages" "Openwrt-Passwall/openwrt-passwall-packages" "main" "name" "xray-core v2ray-geodata sing-box chinadns-ng dns2socks hysteria ipt2socks microsocks naiveproxy shadowsocks-libev shadowsocks-rust shadowsocksr-libev simple-obfs tcping trojan-plus tuic-client v2ray-plugin xray-plugin geoview shadow-tls"
