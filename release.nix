let
  pkgs = import <nixpkgs> {};
  temptory = pkgs.callPackage ./temptory.nix {};

  f = name: extra_flags: pkgs.stdenv.mkDerivation {
    inherit name;
    src = ./.;
    buildInputs = [ pkgs.boehmgc ];
    nativeBuildInputs = [ pkgs.ats temptory ];
    ATSHOME = "${pkgs.ats}";
    TEMPTORY = "${temptory}";
    buildPhase = ''
      tempacc -O2 -flto -s -DATS_MEMALLOC_LIBC -o ${name} ${name}.dats ${extra_flags}
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp ${name} $out/bin/
    '';
  };
in {
  inherit temptory;
  treap = f "treap" "-lgc";
  treap_manual = f "treap_manual" "";
}
