#!/usr/bin/env bash
DIRECTORY=ATS
GCC=gcc
ATSVER=0.2.12
ATSLANGURL_github=http://ats-lang.github.io
ATSPACK=ats-lang-anairiats-${ATSVER}
ATSHOME=${PWD}/${DIRECTORY}/${ATSPACK}
ATSHOMERELOC=ATS-${ATSVER}
PATSHOME=${PWD}/${DIRECTORY}/ATS2
PATSUTILS=${PWD}/${DIRECTORY}/PostiATS-Utilities
PATH=$PATSHOME/bin:$PATSUTILS:${PATH}
PATSCONTRIB=${PWD}/${DIRECTORY}/ATS2-contrib


if [ ! -d "$DIRECTORY" ]; then
  mkdir -p "$DIRECTORY"
fi

if [ ! -f "$PATSHOME/bin/patscc" ]; then
  (cd "$DIRECTORY" &&
    wget https://github.com/ats-lang/ats-lang.github.io/raw/master/ATS-Anairiats/"$ATSPACK".tgz
    tar -zxf "$ATSPACK".tgz
    (cd "$ATSPACK" && ./configure&&make CC=${GCC} all_ngc)
    (cd "$ATSPACK"/ccomp/runtime/GCATS && make && make clean)
    git clone https://github.com/githwxi/ATS-Postiats.git ATS2
    git clone https://github.com/githwxi/ATS-Postiats-contrib.git ATS2-contrib
    (cd ATS2 && cp "$ATSPACK"/config.h .)
    (cd ATS2 && time make -f Makefile_devl)
    (cd ATS2/src && make cleanall)
    (cd ATS2/src/CBOOT && make -C prelude)
    (cd ATS2/src/CBOOT && make -C libc)
    (cd ATS2/src/CBOOT && make -C libats)
    (cd ATS2/utils/libatsopt && make && make clean)
    cp -f ATS2/ccomp/atslib/lib/libatsopt.a "$ATSPACK"/ccomp/lib
    (cd ATS2/contrib/CATS-parsemit && time make all)
    git clone https://github.com/Hibou57/PostiATS-Utilities.git
  )
fi
"$PATSHOME/bin/patscc" -O3 -flto -s -D_GNU_SOURCE -DATS_MEMALLOC_GCBDW -O2 -I${PATSHOME}/contrib -o treap treap.dats -lgc -latslib
rm treap_dats.c
strip treap

"$PATSHOME/bin/patscc" -O3 -flto -s -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -I${PATSHOME}/contrib -O3 -o treap_manual treap_manual.dats -latslib
rm treap_manual_dats.c
strip treap_manual
