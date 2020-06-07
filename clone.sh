#! /usr/bin/env bash
set -euxo pipefail
(( ! $# ))
[[ "$PKG" ]]

git clone --recursive --depth=1    --branch=v2.1.1 \
     https://github.com/StakeShare/StakeShare-Core       \
                                   "$PKG"

