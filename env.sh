#! /usr/bin/env bash
set -euxo pipefail
(( $# ))

ARCH="$(gcc -march=native  -Q --help=target | awk '$1 == "-march=" {print $2}')"
TUNE="$(gcc -march="$ARCH" -Q --help=target | awk '$1 == "-mtune=" {print $2}')"
TUNE="${TUNE:-$ARCH}"

# sanity check
[[ "${ARCH}" ]]
[[ "${TUNE}" ]]

#PARALLEL="-fopenmp -ftree-parallelize-loops=$(nproc)"
PARALLEL=

  CFLAGS="${CFLAGS:-}   -march=$ARCH -mtune=$TUNE ${PARALLEL:-}"
CXXFLAGS="${CXXFLAGS:-} -march=$ARCH -mtune=$TUNE ${PARALLEL:-}"
unset ARCH TUNE PARALLEL

if   [[ "$MODE" = "stage2" ]] ; then
    CFLAGS="$CFLAGS   -fauto-profile=/perf/fbdata.afdo"
  CXXFLAGS="$CXXFLAGS -fauto-profile=/perf/fbdata.afdo"
elif [[ "$MODE" = "stage1" ]] ; then
      CFLAGS="$CFLAGS   -g1"
    CXXFLAGS="$CXXFLAGS -g1"
else exit 1 ; fi

echo     CFLAGS=$CFLAGS
echo   CXXFLAGS=$CXXFLAGS
export CFLAGS CXXFLAGS

$*

