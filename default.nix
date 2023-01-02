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
pkgs.stdenv.mkDerivation rec {
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
    
    mkdir -p ./${connect-cardano-wallet-elm.name}
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
    mkdir -p $out/${name}/src
    cp ./src/Delegation.elm $out/${name}/src
    yarn --offline build-delegate
    cp -r ./dist $out
  '';
}
