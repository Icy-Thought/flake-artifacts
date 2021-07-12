{ config, lib, pkgs, ... }: {

  imports = [
    ../home-manager/picom
    ../home-manager/rofi
    ../home-manager/dunst
    ../home-manager/xresources
    ../home-manager/xsession
  ];

  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;

    extraPackages = haskellPackages: [
      haskellPackages.dbus
      haskellPackages.monad-logger
    ];
  };

  home.sessionVariables = {
    XMONAD_CONFIG_DIR = "${config.xdg.configHome}/xmonad";
    XMONAD_CACHE_DIR = "${config.xdg.cacheHome}/xmonad";
    XMONAD_DATA_DIR = "${config.xdg.dataHome}/xmonad";
  };

  home.file = {
    "${config.xdg.configHome}/xmonad" = {
      source = ./xmonad-icy;
      recursive = true;
    };
  };
}
