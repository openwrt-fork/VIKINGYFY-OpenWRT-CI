#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

set -e

BASE_CONFIG="$1"
OVERRIDE_CONFIG="$2"

if [ -z "$BASE_CONFIG" ] || [ -z "$OVERRIDE_CONFIG" ]; then
	echo "Usage: $0 <base-config> <override-config>" >&2
	exit 1
fi

if [ ! -f "$BASE_CONFIG" ]; then
	echo "Base config not found: $BASE_CONFIG" >&2
	exit 1
fi

if [ ! -f "$OVERRIDE_CONFIG" ]; then
	echo "Override config not found: $OVERRIDE_CONFIG" >&2
	exit 1
fi

awk '
	FNR == NR {
		if ($0 ~ /^(# )?CONFIG_[A-Za-z0-9_-]+(=.*| is not set)$/) {
			key = $0
			sub(/^# /, "", key)
			sub(/=.*/, "", key)
			sub(/ is not set$/, "", key)
			override[key] = 1
		}
		next
	}

	{
		key = ""
		if ($0 ~ /^(# )?CONFIG_[A-Za-z0-9_-]+(=.*| is not set)$/) {
			key = $0
			sub(/^# /, "", key)
			sub(/=.*/, "", key)
			sub(/ is not set$/, "", key)
		}

		if (key == "" || !(key in override)) print
	}
' "$OVERRIDE_CONFIG" "$BASE_CONFIG"

cat "$OVERRIDE_CONFIG"
