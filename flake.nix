# {
#   description = "A very basic flake";
  
#   inputs = {
#     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#     flake-utils.url = "github:numtide/flake-utils";
#    };

#   outputs = { self, nixpkgs , flake-utils}: 
   
#    {

#     packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

#     defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;

#     supportedGHCVersion = "921";
#     compilerVersion = "ghc921";
#     pkgs = nixpkgs.legacyPackages.${system};
#     hsPkgs = pkgs.haskell.packages.${compilerVersion};

#   };
# }


{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
   };

  outputs = { self, nixpkgs , flake-utils}: 
  let
    utils = flake-utils.lib;
  in
    utils.eachDefaultSystem (system: let
      supportedGHCVersion = "922";
      compilerVersion = "ghc${supportedGHCVersion}";
      pkgs = nixpkgs.legacyPackages.${system};
      containers = hsPkgs.callHackage "containers" "0.6.4.1" {};
      hsPkgs = pkgs.haskell.packages.${compilerVersion}.override {
        overrides = hfinal: hprev: {
          aaa = hfinal.callCabal2nix "aaa" ./. {};
          containers = hfinal.callHackage "containers" "0.6.4.1" {};
        };
      };
    in rec {
      packages =
        utils.flattenTree
        {
          aaa = hsPkgs.aaa;
          inherit containers;
        };

      # nix develop
      devShell = hsPkgs.shellFor {
        withHoogle = true;
        packages = p: [
          p.aaa
          p.containers
        ];
        buildInputs = with pkgs;
          [
            hsPkgs.haskell-language-server
            haskellPackages.cabal-install
            cabal2nix
            haskellPackages.ghcid
            haskellPackages.fourmolu
            haskellPackages.cabal-fmt
            nodePackages.serve
            containers
          ]
          ++ (builtins.attrValues (import ./scripts.nix {s = pkgs.writeShellScriptBin;}));
      };

      # nix build
      defaultPackage = packages.aaa;
    });
}


  #  {

  #   packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

  #   defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;

  #   supportedGHCVersion = "921";
  #   compilerVersion = "ghc921";
  #   pkgs = nixpkgs.legacyPackages.${system};
  #   hsPkgs = pkgs.haskell.packages.${compilerVersion};

  # };