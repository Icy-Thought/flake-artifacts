{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.zsh;
  zshDir = "${config.snowflake.configDir}/zsh";
  themeCfg = config.modules.themes;
in {
  options.modules.shell.zsh = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      any-nix-shell
      fzf
      pwgen
      yt-dlp
      csview

      # GNU Alternatives
      bottom
      exa
      fd
      (ripgrep.override {withPCRE2 = true;})
      zoxide
    ];

    # Custom shell modules:
    modules.shell.xplr.enable = true;
    modules.shell.macchina.enable = true;

    # Enable starship-rs:
    modules.shell.starship.enable = true;
    hm.programs.starship.enableZshIntegration = true;

    programs.zsh = {
      enable = true;
      histSize = 10000;
      histFile = "$XDG_CONFIG_HOME/zsh/history";

      autosuggestions = {
        enable = true;
        strategy = "match_prev_cmd";
        highlightStyle = "fg=${bright.black},bold,underline";
      };
      enableCompletion = true;
      # enableGlobalCompInit = true;

      syntaxHighlighting = {
        enable = true;
        highlighters = ["main" "brackets" "cursor" "root" "line"];
      };

      ohMyZsh = {
        enable = true;
        plugins = [
          "vi-mode"
          "colored-man-pages"
          "history-substring-search"
        ];
        customPkgs = let
          zsh-abbr = {
            src = pkgs.fetchFromGitHub {
              owner = "olets";
              repo = "zsh-abbr";
              rev = "v4.8.0";
              sha256 = "diitszKbu530zXbJx4xmfOjLsITE9ucmWdsz9VTXsKg=";
            };
          };
        in (with pkgs; [
          zsh-nix-shell
          zsh-fzf-tab
          zsh-autopair
          zsh-you-should-use
          zsh-abbr
        ]);
      };

      promptInit = let
        fzf-theme = pkgs.writeShellScript "fzf.config" (with themeCfg.colors.main; ''
          export FZF_DEFAULT_OPTS=" \
          --color=bg:,bg+:${types.bg},spinner:${types.panelbg},hl:${normal.red} \
          --color=fg:${types.border},header:${normal.red},info:${normal.magenta},pointer:${types.border} \
          --color=marker:${normal.magenta},fg+:${types.border},prompt:${types.border},hl+:${normal.red}"
        '');
      in ''
        #
        # -------===[ History-Substring-Search ]===------- #
        ## Bind `<Up>` and `<Down>` arrow-keys
        bindkey "^[[A" history-substring-search-up
        bindkey "^[[B" history-substring-search-down

        ## Bind `j` and `k` in VI-Mode
        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down

        # `jk` For normal-mode
        bindkey 'jk' vi-cmd-mode

        # -------===[ Plugin Management ]===------- #
        source ${pkgs.fzf-zsh}/share/zsh/plugins/fzf-zsh/fzf-zsh.plugin.zsh
        source ${fzf-theme}
      '';

      interactiveShellInit = ''
        # -------===[ General ]===------- #
        unsetopt BRACE_CCL                  # Brace character class list expansion.
        setopt COMBINING_CHARS              # Zero-length punc chars + Base char.
        setopt RC_QUOTES                    # Allow single-quotes inside double-quotes.
        setopt HASH_LIST_ALL                # Hash cmd-path on cmp || spell-correction.
        unsetopt CORRECT_ALL                # Don't correct mis-spellings in args.
        unsetopt NOMATCH                    # Don't print err on no matches.
        unsetopt BEEP                       # Don't disturb the silence.
        setopt IGNORE_EOF                   # Don't exit on End-Of-File.
        WORDCHARS='_-*?[]~&.;!#$%^(){}<>'   # Special chars == part of a word!

        # -------===[ History ]===------- #
        setopt HIST_BEEP                    # Beep on non-existent history access.
        setopt HIST_EXPIRE_DUPS_FIRST       # Expire duplicate entries first.
        setopt HIST_FIND_NO_DUPS            # Don't display previously found entries.
        setopt HIST_IGNORE_ALL_DUPS         # No duplicate entries!
        setopt HIST_IGNORE_DUPS             # Don't record entries twice in a row.
        setopt HIST_IGNORE_SPACE            # Don't record whitespace entries.
        setopt HIST_REDUCE_BLANKS           # Remove superfluous blanks before recording entry.
        setopt HIST_SAVE_NO_DUPS            # Don't write duplicate entires.
        setopt HIST_VERIFY                  # Don't execute on expansion!

        # -------===[ Jobs ]===------- #
        setopt LONG_LIST_JOBS               # Long format job list.
        setopt NOTIFY                       # Report process status.
        unsetopt BG_NICE                    # Don't run all bg-jobs at a lower priority.
        unsetopt HUP                        # Don't kill jobs on shell exit.
        unsetopt CHECK_JOBS                 # Don't report on jobs on shell exit.

        # -------===[ Directories ]===------- #
        setopt AUTO_PUSHD                   # Push old dir -> stack on cd.
        setopt PUSHD_IGNORE_DUPS            # Don't store duplicates in stack.
        setopt PUSHD_SILENT                 # Don't print dir stack after pushd || popd.
        setopt PUSHD_TO_HOME                # Push `~/.` when no argument is given.
        setopt CDABLE_VARS                  # Change directory -> path stored in var.
        setopt MULTIOS                      # Write -> multiple descriptors.
        setopt EXTENDED_GLOB                # Use extended globbing syntax.
        unsetopt GLOB_DOTS
        unsetopt AUTO_NAME_DIRS             # Don't add variable-stored paths to ~ list

        # -------===[ Plugin Management ]===------- #
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh

        eval "$(zoxide init zsh)"

        # -------===[ Aesthetics ]===------- #
        source "$HOME/.config/zsh/${themeCfg.active}.zsh"
        source "$HOME/.config/zsh/fzf.zsh"
      '';

      shellAliases = {
        exa = "exa --group-directories-first";
      };
    };

    environment.variables = {
      FZF_DEFAULT_COMMAND = "${getExe ripgrep} --files --no-ignore --hidden --follow --glob '!.git/*'";
    };

    home.configFile = {
      "zsh/abbreviations".text = ''
        ${builtins.readFile "${zshDir}/abbreviations/main.zsh"}
        ${builtins.readFile "${zshDir}/abbreviations/git.zsh"}
      '';
    };
  };
}
