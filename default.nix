{ pkgs ? import <nixpkgs> { }
}:

let
  yarnPkg = pkgs.mkYarnPackage {
    name = "cardano-delegation-elm-node-packages";
    src = ./.;
    doDist = false;
    publishBinsFor = [ "webpack" "webpack-cli" ];
  };
  connect-cardano-wallet-elm = import ../connect-cardano-wallet-elm { };
in
pkgs.stdenv.mkDerivation {
  name = "cardano-delegation-elm";
  src = pkgs.lib.cleanSource ./.;

  buildInputs = with pkgs.elmPackages; [
    connect-cardano-wallet-elm
    elm
    elm-format
    yarnPkg
    pkgs.yarn
    pkgs.nodePackages.webpack
    pkgs.nodePackages.webpack-cli
  ];

  patchPhase = ''
    rm -rf elm-stuff
    echo hellow
    mkdir -p ./${connect-cardano-wallet-elm.name}
    ls ${connect-cardano-wallet-elm}/${connect-cardano-wallet-elm.name}
    cp -r ${connect-cardano-wallet-elm}/${connect-cardano-wallet-elm.name} ../${connect-cardano-wallet-elm.name}
    ln -s ${yarnPkg}/libexec/${yarnPkg.name}/node_modules ./node_modules
    export PATH="${yarnPkg}/bin:$PATH"
  '';

  configurePhase = pkgs.elmPackages.fetchElmDeps {
    elmVersion = "0.19.1";
    elmPackages = import ./elm-src.nix;
    registryDat = ./registry.dat;
  };

  installPhase = ''
    mkdir -p $out
    yarn --offline build-delegate
    cp -r ./dist $out
  '';
}
