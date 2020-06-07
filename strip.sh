#! /usr/bin/env bash
set -u
(( ! $# ))

find /usr/local/lib*                \
  -iname \*.so -o -iname \*.a       \
  -exec strip -R .comment      {} + \
  -exec strip --strip-debug    {} + \
  -exec strip --strip-unneeded {} + 2> /dev/null || :
find /usr/local/bin                 \
  \! -type d                        \
  \! -name addr2line                \
  \! -name x86_64-linux-musl-gcc-nm     \
  \! -name x86_64-linux-musl-gcc-9.3.0  \
  \! -name x86_64-linux-musl-gcc-ar     \
  \! -name strings                  \
  \! -name nm                       \
  \! -name ld                       \
  \! -name readelf                  \
  \! -name c++filt                  \
  \! -name x86_64-linux-musl-c++    \
  \! -name gcc-nm                   \
  \! -name strip                    \
  \! -name x86_64-linux-musl-g++    \
  \! -name gcov                     \
  \! -name cpp                      \
  \! -name gcc-ranlib               \
  \! -name as                       \
  \! -name ld.bfd                   \
  \! -name x86_64-linux-musl-gfortran   \
  \! -name elfedit                  \
  \! -name gcc                      \
  \! -name ar                       \
  \! -name x86_64-linux-musl-cc     \
  \! -name gprof                    \
  \! -name objdump                  \
  \! -name x86_64-linux-musl-gcc    \
  \! -name x86_64-linux-musl-gcc-ranlib \
  \! -name gcov-dump                \
  \! -name gcov-tool                \
  \! -name gfortran                 \
  \! -name size                     \
  \! -name objcopy                  \
  \! -name g++                      \
  \! -name ranlib                   \
  \! -name gcc-ar                   \
  \! -name c++                      \
  \! -name cc                       \
  -exec grep -IL .            {} \; \
  -exec strip --strip-all     {} +  \
  -exec upx-ucl --ultra-brute       \
                --all-filters {} + 2> /dev/null || :

