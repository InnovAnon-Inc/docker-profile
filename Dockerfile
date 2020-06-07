FROM innovanon/poobuntu-16.04:latest

COPY dpkg.list manual.list /

RUN apt-fast update                   \
 && apt-fast full-upgrade             \
 && apt-fast install $(cat dpkg.list)

RUN useradd -ms /bin/bash lfs         \
 && mkdir -v         /mnt/lfs /perf   \
 && chown -v lfs:lfs /mnt/lfs /perf
USER lfs
RUN mkdir -v         /mnt/lfs/sources \
                     /mnt/lfs/build

ARG MODE
ENV MODE="$MODE"

ARG PKG
ENV PKG="$PKG"

ARG BIN
ENV BIN="$BIN"

# TODO set stage2 flags
# for static lib... StakeShare doesn't seem to like it
#ENV DEADCODESTRIP='-Wl,-static -fvtable-gc -fdata-sections -ffunction-sections -Wl,--gc-sections -Wl,-s'
#ENV        COMMON="-flto -flto-compression-level=9 -fuse-linker-plugin $DEADCODESTRIP"
#ENV          MATH='-ffast-math -fassociative-math -freciprocal-math -fsingle-precision-constant -mpc32'
#ENV          TEST='-fmodulo-sched -fmodulo-sched-allow-regmoves -fgcse-sm -fgcse-las -fgcse-after-reload'
#ENV           OPT='-fmerge-all-constants -fipa-pta'
#ENV           ISL='-floop-nest-optimize -fgraphite-identity -floop-parallelize-all'
#ENV         SMALL='-Os'
#ENV    AGGRESSIVE='-faggressive-loop-optimizations -fsched-stalled-insns=0 -freorder-blocks-algorithm=stc -fivopts -ftree-loop-distribution -ftree-loop-distribute-patterns -ftree-loop-vectorize -ftree-vectorize -funroll-loops -fmove-loop-invariants -fsplit-loops -funswitch-loops -fdelete-dead-exceptions'

ENV DEADCODESTRIP=
ENV        COMMON=
ENV          MATH=
ENV          TEST=
ENV         SMALL=
ENV    AGGRESSIVE=
ENV          CCXX="$COMMON $MATH $TEST $OPT $ISL $SMALL $AGGRESSIVE"
ENV   CFLAGS="$CCXX"
#ENV CXXFLAGS="$CCXX -fdevirtualize-speculatively -fdevirtualize-at-ltrans"
ENV CXXFLAGS="$CCXX"
ENV  LDFLAGS="$COMMON"

#ENV CFLAGS="-static -static-libgcc"
#ENV CXXFLAGS="-static-libstdc++"
#ENV LDFLAGS="-s --static"
ENV ACFLAGS="--disable-shared --enable-static"

COPY clone.sh configure.sh build.sh /

# clone repo
RUN if [ "$MODE" = "stage1" ] ; then                                 \
      mkdir -v      /mnt/lfs/repos                                   \
   && cd            /mnt/lfs/repos                                   \
      /clone.sh                                                      \
   || exit $? ; fi

# create src pkg
RUN if [ "$MODE" = "stage1" ] ; then                                 \
      cd            /mnt/lfs/repos/"$PKG"                            \
   && /configure.sh                                                  \
   && cd            /mnt/lfs/repos                                   \
   && tar acf       /mnt/lfs/sources/"$PKG".txz "$PKG" --exclude-vcs \
   || exit $? ; fi

# shared: env, entrypoint
# stage1: profile
# stage2: strip, sources, perf
COPY env.sh profile.sh strip.sh entrypoint.sh /
COPY ./sources/*  /mnt/lfs/sources
COPY ./perf/*     /perf

# convert perf to afdo
RUN if [ "$MODE" = "stage2" ] ; then                                 \
      create_gcov --binary="$BIN"                                    \
                  --profile=/perf/perf.data                          \
                  --gcov=/perf/fbdata.afdo                           \
   || exit $? ; fi

# compile src pkg => bin (pkg)
RUN tar  xf       /mnt/lfs/sources/"$PKG".txz -C /mnt/lfs/build      \
 && cd            /mnt/lfs/build/"$PKG" \
 && /build.sh

# install pkg, strip if stage2
USER root
RUN cd              /mnt/lfs/build/"$PKG"/build                      \
 && make install                                                     \
 && cd              /                                                \
 && if [ "$MODE" = "stage2" ] ; then                                 \
      /strip.sh || exit $? ;                                         \
    fi                                                               \
 && rm -rf          /mnt/lfs/build                                   \
                    /mnt/lfs/repos                                   \
 && rm -v /strip.sh /env.sh

#RUN apt-mark manual $(manual.list)      \
# && apt-fast purge  $(cat dpkg.list)    \
# && /poobuntu-clean.sh                  \
# && rm -v /dpkg.list /manual.list       \
# && if [ "$MODE" -eq "stage2" ] ; then  \
#      rm -rf /perf /mnt/lfs /profile.sh \
#   || exit $? ; fi

# GUI stuff
RUN usermod -a -G audio lfs \
 && usermod -a -G video lfs ; 

USER lfs
WORKDIR /home/lfs
ENTRYPOINT ["/entrypoint.sh"]
