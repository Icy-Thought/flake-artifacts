{ config, lib, pkgs, ... }:

let
  launch_eww = pkgs.writeScriptBin "launch-eww" ''
    ## Files and cmd
    FILE="${config.xdg.cacheHome}/eww_launch.xyz"
    EWW="${config.home.homeDirectory}/.bin/eww"

    ## Run eww daemon if not running already
    if [[ ! `pidof eww` ]]; then
      ''${EWW} daemon
      sleep 1
    fi

    ## Open widgets
    run_eww() {
      ''${EWW} open-many \
           background \
           profile \
           system \
           clock \
           uptime \
           music \
           github \
           reddit \
           twitter \
           youtube \
           weather \
           apps \
           mail \
           logout \
           sleep \
           reboot \
           poweroff \
           folders
    }

    ## Launch or close widgets accordingly
    if [[ ! -f "$FILE" ]]; then
      touch "$FILE"
      run_eww
    else
      ''${EWW} close-all
      rm "$FILE"
    fi
  '';

in {
  home.packages = [ launch_eww ];

  xdg.configFile."eww" = {
    source = ./config;
    recursive = true;
  };
}
