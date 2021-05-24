{ ats, gcc, gmp, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "ATS-Temptory";

  buildInputs = [ gmp ];
  nativeBuildInputs = [ ats ];

  src = fetchFromGitHub {
    owner = "githwxi";
    repo = "ATS-Temptory";
    rev = "be0d7b178c2a9dc3977acb233f86cb4819e6bed9";
    sha256 = "sha256-kSJtzdNuN7TUd6iHw9m1MS3wCyDW8pd1gzwM5yys344=";
  };

  ATSHOME = "${ats}";

  buildPhase = ''
    export TEMPTORY=$(pwd)
    (cd srcgen && make -j$NIX_BUILD_CORES -f Makefile)
    cp srcgen/BUILD/tempopt bin/
    (cd srcgen && make -j$NIX_BUILD_CORES CBOOT)
    (cd srcgen/CBOOT && make -j$NIX_BUILD_CORES tempopt && ./tempopt)
    (cd utils/tempacc && make -j$NIX_BUILD_CORES copy build)
    cp utils/tempacc/BUILD/tempacc bin/
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share
    cp bin/* $out/bin/
    cp -r libats $out/
    cp -r share/HATS $out/share/
    cp -r ccomp $out/
  '';
}
