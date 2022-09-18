_: pkgs: {
  haskellPackages = pkgs.haskellPackages.override (old: {
    overrides =
      pkgs.lib.composeExtensions (old.overrides or (_: _: {}))
      (final: prev: {
        my-xmonad =
          final.callCabal2nix "my-xmonad"
          (pkgs.lib.sourceByRegex ./. ["xmonad.hs" "my-xmonad.cabal"]) {};
      });
  });
}
