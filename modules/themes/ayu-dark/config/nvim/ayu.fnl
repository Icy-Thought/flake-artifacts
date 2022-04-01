(local {: setup} (require :ayu))

(setup {:mirage true
        :overrides {}})

(local lualine (require :lualine))

(lualine.setup {:options {:theme :ayu}})

;; Finally, set the damn colorscheme..
(vim.cmd "colorscheme catppuccin")
