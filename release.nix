let
  pkgs = import <nixpkgs> {};
  temptory = pkgs.callPackage ./temptory.nix {};

  f = name: pkgs.stdenv.mkDerivation {
    inherit name;
    src = ./.;
    nativeBuildInputs = with pkgs; [ ats temptory ];
    ATSHOME = "${pkgs.ats}";
    TEMPTORY = "${temptory}";
    buildPhase = ''
      tempacc -O2 -flto -s -DATS_MEMALLOC_LIBC -o ${name} ${name}.dats
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp ${name} $out/bin/
    '';
  };
in {
  inherit temptory;
  treap = f "treap";
  treap_manual = f "treap_manual";
}
