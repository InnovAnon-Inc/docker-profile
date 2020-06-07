#! /usr/bin/env bash
set -euo pipefail
(( $# ))

#T="$(mktemp -p /perf XXXXXX.data)"
T=/perf/perf.data
perf record                  \
  -e branch-instructions     \
  -e branch-misses           \
  -e cache-misses            \
  -e cache-references        \
  -e cpu-cycles              \
  -e instructions            \
  -e mem-loads               \
  -e ref-cycles              \
  -e stalled-cycles-backend  \
  -e stalled-cycles-frontend \
  -b -o "$T" -- $*

