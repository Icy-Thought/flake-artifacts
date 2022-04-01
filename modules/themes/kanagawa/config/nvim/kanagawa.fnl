(local {: setup} (require :kanagawa))

(setup {:undercurl true
        :commentStyle :italic
        :functionStyle [:bold :italic]
        :keywordStyle :italic
        :statementStyle :bold
        :typeStyle :NONE
        :variablebuiltinStyle :italic
        :specialReturn true
        :specialException true
        :transparent false
        :dimInactive true
        :colors {}
        :overrides {}})

(local lualine (require :lualine))

(lualine.setup {:options {:theme :kanagawa}})

;; Finally, set the damn colorscheme..
(vim.cmd "colorscheme kanagawa")
