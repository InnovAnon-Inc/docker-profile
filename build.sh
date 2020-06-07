#! /usr/bin/env bash
set -euxo pipefail
(( ! $# ))

mkdir build
cd    build
/env.sh ../configure $ACFLAGS
        --with-incompatible-bdb --disable-tests
make

