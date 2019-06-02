#!/usr/bin/env bash
DIRECTORY=ATS
GCC=gcc
ATSVER=0.2.12
ATSLANGURL_github=http://ats-lang.github.io
ATSPACK=ats-lang-anairiats-${ATSVER}
export ATSHOME=${PWD}/${DIRECTORY}/${ATSPACK}
export ATSHOMERELOC=ATS-${ATSVER}
export PATSHOME=${PWD}/${DIRECTORY}/ATS2
PATSUTILS=${PWD}/${DIRECTORY}/PostiATS-Utilities
export PATSCONTRIB=${PWD}/${DIRECTORY}/ATS2-contrib
export TEMPTORY=${PWD}/${DIRECTORY}/ATS-Temptory
PATH=$PATSHOME/bin:$PATSUTILS:${TEMPTORY}/bin:${PATH}

if [ ! -d "$DIRECTORY" ]; then
  mkdir -p "$DIRECTORY"
fi

if [ ! -f "$ATSHOME/bin/atsopt" ];then
  (cd "$DIRECTORY" &&
    wget https://github.com/ats-lang/ats-lang.github.io/raw/master/ATS-Anairiats/"$ATSPACK".tgz
  tar -zxf "$ATSPACK".tgz
  (cd "$ATSPACK" && ./configure && make CC=${GCC} all_ngc)
  (cd "$ATSPACK"/ccomp/runtime/GCATS && make && make clean))
fi

if [ ! -f "$PATSHOME/bin/patsopt" ];then
    (cd "$DIRECTORY" &&
      git clone --depth=1 https://github.com/githwxi/ATS-Postiats.git ATS2
      git clone --depth=1 https://github.com/githwxi/ATS-Postiats-contrib.git ATS2-contrib
      (cd ATS2 && cp "$ATSPACK"/config.h .)
      (cd ATS2 && time make -f Makefile_devl)
      (cd ATS2/src && make cleanall)
      (cd ATS2/src/CBOOT && make -C prelude)
      (cd ATS2/src/CBOOT && make -C libc)
      (cd ATS2/src/CBOOT && make -C libats)
      (cd ATS2/utils/libatsopt && make && make clean)
      cp -f ATS2/ccomp/atslib/lib/libatsopt.a "$ATSPACK"/ccomp/lib
      (cd ATS2/contrib/CATS-parsemit && time make all))
fi

if [ ! -f "$TEMPTORY/bin/tempacc" ]; then
  (cd "$DIRECTORY" &&
    git clone git@github.com:githwxi/ATS-Temptory
    (cd "$TEMPTORY" &&
      (cd srcgen && make -f Makefile) &&
      (cp -f srcgen/BUILD/tempopt bin/tempopt) &&
      (cd srcgen && make CBOOT) &&
      (cd srcgen/CBOOT && make tempopt && ./tempopt) &&
      (cd utils/tempacc && make copy build) &&
      (cp utils/tempacc/BUILD/tempacc bin/.)))
fi

"$TEMPTORY/bin/tempacc" -O2 -flto -s -DATS_MEMALLOC_LIBC -o treap treap.dats -lgc
strip treap

"$TEMPTORY/bin/tempacc" -O2 -flto -s -DATS_MEMALLOC_LIBC -o treap_manual treap_manual.dats
strip treap_manual
