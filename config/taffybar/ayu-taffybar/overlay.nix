_: pkgs: {
  haskellPackages = pkgs.haskellPackages.override (old: {
    overrides =
      pkgs.lib.composeExtensions (old.overrides or (_: _: { }))
        (final: prev: {
          my-taffybar =
            final.callCabal2nix "my-taffybar"
              (pkgs.lib.sourceByRegex ./. [
                "taffybar.hs"
                "taffybar.css"
                "catppuccin.css"
                "my-taffybar.cabal"
              ])
              { };
        });
  });
}
