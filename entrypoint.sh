#! /usr/bin/env bash
set -euo pipefail
(( ! $# ))
[[ "$PKG" ]]
[[ "$BIN" ]]

if   [[ "$MODE" = "stage1" ]] ; then
  cp -u /mnt/lfs/sources/"$PKG".txz /sources/
  /profile.sh "$BIN"
elif [[ "$MODE" = "stage2" ]] ; then
  "$BIN"
else exit 1 ; fi

