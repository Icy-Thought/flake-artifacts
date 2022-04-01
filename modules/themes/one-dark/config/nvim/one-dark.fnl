(local {: setup : load} (require :onedarkpro))

(setup {:theme (fn []
                 (if (= vim.o.background :dark) :onedark :onelight))
        :colors {}
        :hlgroups {}
        :filetype_hlgroups {}
        :plugins {:native_lsp true
                  :polygot true
                  :treesitter true}
        :styles {:comments :italic
                 :functions [:italic :bold]
                 :keywords :italic
                 :strings :NONE
                 :variables :NONE}
        :options {:bold false
                  :italic false
                  :underline false
                  :undercurl false
                  :cursorline false
                  :transparency false
                  :terminal_colors false
                  :window_unfocussed_color false}})
(load)

(local lualine (require :lualine))

(lualine.setup {:options {:theme :onedarkpro}})

;; Finally, set the damn colorscheme..
(vim.cmd "colorscheme catppuccin")
