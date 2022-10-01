{ inputs
, options
, config
, lib
, pkgs
, ...
}:
with lib;
with lib.my; {
  options.modules.desktop.xmonad = {
    enable = mkBoolOpt false;
  };

  config = mkIf config.modules.desktop.xmonad.enable {
    nixpkgs.overlays = with inputs; [
      xmonad.overlay
      xmonad-contrib.overlay
    ];

    environment.systemPackages = with pkgs; [
      haskellPackages.my-xmonad
      lightdm
      libnotify
      playerctl
      gxmessage
      xdotool
      xclip
      feh
    ];

    # Our beloved modules
    modules.desktop = {
      media.browser.nautilus.enable = true;
      extra = {
        dunst.enable = true;
        fcitx5.enable = true;
        mimeApps.enable = true; # mimeApps -> default launch application
        picom.enable = true;
        rofi.enable = true;
        taffybar.enable = true;
      };
    };

    services.xserver = {
      enable = true;
      displayManager = {
        defaultSession = "none+xmonad";
        lightdm.enable = true;
        lightdm.greeters.mini.enable = true;
      };

      windowManager.session = [{
        name = "xmonad";
        start = ''
          /usr/bin/env my-xmonad &
          waitPID=$!
        '';
      }];
    };

    services = {
      autorandr.enable = true;
      blueman.enable = true;
    };

    hm.services = {
      blueman-applet.enable = true;
      gnome-keyring.enable = true;
      network-manager-applet.enable = true;
      status-notifier-watcher.enable = true;
    };

    hm.xsession = {
      enable = true;
      numlock.enable = true;
      preferStatusNotifierItems = true;
      windowManager.command = "${getExe pkgs.haskellPackages.my-xmonad}";
      importedVariables = [ "GDK_PIXBUF_MODULE_FILE" ];
    };
  };
}
