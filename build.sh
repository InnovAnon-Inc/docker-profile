#! /usr/bin/env bash
set -euxo pipefail
(( ! $# ))
echo "$PWD" |
grep -q /mnt/lfs/build/"$PKG"

mkdir build
cd    build
/env.sh ../configure $ACFLAGS \
        --with-incompatible-bdb --disable-tests
# TODO remove -j1: unreadable errors
make -j1

