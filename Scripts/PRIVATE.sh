#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

if [[ "$WRT_CONFIG" == "ZN-M2-WIFI-NO" ]]; then
	UPDATE_PACKAGE "nps-openwrt" "djylb/nps-openwrt" "main" "" "npc nps luci-app-npc luci-app-nps"
fi
