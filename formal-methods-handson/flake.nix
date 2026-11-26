{
  description = "形式手法ハンズオン (Lean 4 / TLA+ / Alloy 6) の開発環境";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        jdk = pkgs.jdk17;

        # TLA+ ツール(TLC / PlusCal トランスレータ)。バージョン固定。
        tla2tools = pkgs.fetchurl {
          url = "https://github.com/tlaplus/tlaplus/releases/download/v1.7.4/tla2tools.jar";
          sha256 = "936a262061c914694dfd669a543be24573c45d5aa0ff20a8b96b23d01e050e88";
        };

        # Alloy 6 (GUI + CLI)。バージョン固定。
        alloyJar = pkgs.fetchurl {
          url = "https://github.com/AlloyTools/org.alloytools.alloy/releases/download/v6.2.0/org.alloytools.alloy.dist.jar";
          sha256 = "6b8c1cb5bc93bedfc7c61435c4e1ab6e688a242dc702a394628d9a9801edb78d";
        };

        tlc = pkgs.writeShellScriptBin "tlc" ''
          exec ${jdk}/bin/java -XX:+UseParallelGC -cp ${tla2tools} tlc2.TLC "$@"
        '';
        pcal = pkgs.writeShellScriptBin "pcal" ''
          exec ${jdk}/bin/java -cp ${tla2tools} pcal.trans "$@"
        '';
        alloy = pkgs.writeShellScriptBin "alloy" ''
          exec ${jdk}/bin/java -jar ${alloyJar} "$@"
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.lean4   # lean / lake(nixpkgs 版。lean-toolchain は無視される)
            jdk
            tlc
            pcal
            alloy
          ];

          shellHook = ''
            export TLA_JAR=${tla2tools}
            echo "Lean:  $(lean --version)"
            echo "TLA+:  tlc / pcal    (TLA_JAR=$TLA_JAR)"
            echo "Alloy: alloy [exec ...]"
          '';
        };
      });
}
