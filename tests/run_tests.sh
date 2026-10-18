#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
LUA=${LUA:-lua}
LUAC=${LUAC:-luac}
for source in ./*.lua tests/*.lua; do "$LUAC" -p "$source"; done
"$LUA" tests/run.lua deDE
"$LUA" tests/run.lua enUS
"$LUA" tests/export_test.lua
"$LUA" tests/minimap_test.lua
