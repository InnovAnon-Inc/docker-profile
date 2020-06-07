#! /usr/bin/env bash
set -euxo pipefail
(( ! $# ))
echo "$PWD" |
grep -q /mnt/lfs/sources/"$PKG"

mkdir build
cd    build
/env.sh ../configure $ACFLAGS
        --with-incompatible-bdb --disable-tests
make

