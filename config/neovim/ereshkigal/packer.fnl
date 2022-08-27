(use-package! :gelguy/wilder.nvim
              {:run :UpdateRemotePlugins
               :event :CmdlineEnter
               :requires [(pack :romgrk/fzy-lua-native)]
               :config (load-file ui.wilder)})
