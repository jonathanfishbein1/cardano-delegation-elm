{
  description = "cardano-delegation-elm-flake";
  inputs.connect-cardano-wallet-elm.url = "path:/home/jonathan/Documents/connect-cardano-wallet-elm/";

  outputs = { self, nixpkgs, connect-cardano-wallet-elm }: rec {
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };
    yarnPkg = pkgs.mkYarnPackage {
      name = "cardano-delegation-elm-node-packages";
      src = ./.;
      doDist = false;
      publishBinsFor = [ "webpack" "webpack-cli" ];
    };

    cardano-delegation-elm-package = pkgs.stdenv.mkDerivation rec {
      name = "cardano-delegation-elm";
      src = pkgs.lib.cleanSource ./.;

      buildInputs = with pkgs.elmPackages; [
        connect-cardano-wallet-elm.connect-cardano-wallet-elm-package
        elm
        elm-format
        yarnPkg
        pkgs.yarn
        pkgs.nodePackages.webpack
        pkgs.nodePackages.webpack-cli
      ];

      patchPhase = ''
        rm -rf elm-stuff
    
        mkdir -p ./${connect-cardano-wallet-elm.connect-cardano-wallet-elm-package.name}
        cp -r ${connect-cardano-wallet-elm.connect-cardano-wallet-elm-package}/${connect-cardano-wallet-elm.connect-cardano-wallet-elm-package.name} ../${connect-cardano-wallet-elm.connect-cardano-wallet-elm-package.name}
    
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
    };

    packages.x86_64-linux.default = cardano-delegation-elm-package;

  };
}
