#! /usr/bin/env bash
set -euxo pipefail
(( ! $# ))

echo "$PWD" |
grep -q /mnt/lfs/repos/"$PKG"

./autogen.sh

