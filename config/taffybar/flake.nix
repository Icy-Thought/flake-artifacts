{
  inputs = {
    taffybar.url = "github:taffybar/taffybar";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, taffybar, nixpkgs }:
    let
      overlay = import ./overlay.nix;
      overlays = taffybar.overlays ++ [ overlay ];
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowBroken = true;
        };
      in {
        devShells.default =
          pkgs.haskellPackages.shellFor { packages = p: [ p.my-taffybar ]; };
        packages.default = pkgs.haskellPackages.my-taffybar;
      }) // {
        inherit overlay overlays;
      };
}
