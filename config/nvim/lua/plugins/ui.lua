local ember = {
    base    = "#0a0a0b",
    surface = "#16181b",
    overlay = "#202327",
    muted   = "#3a3e44",
    ember   = "#6f94ac", -- accent
    amber   = "#9fb0ba", -- ice
    text    = "#e4e6e9",
    dim     = "#8b9097",
    bright  = "#ffffff",
}

return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = true,
                dim_inactive = { enabled = true, shade = "dark", percentage = 0.12 },
                styles = {
                    comments  = { "italic" },
                    keywords  = {},
                    functions = { "italic" },
                },
                -- Remap the whole mocha palette onto the amalthea steel ramp. Neutrals become
                -- true near-blacks; accents lean steel-blue/ice while keeping the
                -- diagnostic colours (red/yellow/green/blue) distinguishable.
                color_overrides = {
                    mocha = {
                        rosewater = "#d4d6da",
                        flamingo  = "#a9b0b8",
                        pink      = ember.amber,
                        mauve     = ember.ember,
                        red       = "#b3555a",
                        maroon    = "#96585c",
                        peach     = "#998f7a",
                        yellow    = "#a89a6e",
                        green     = "#8fab97",
                        teal      = "#8fb3ac",
                        sky       = "#8fabc0",
                        sapphire  = "#6a8ba3",
                        blue      = "#5f7e91",
                        lavender  = "#8a7a95",
                        text      = ember.text,
                        subtext1  = "#c3c6cb",
                        subtext0  = ember.dim,
                        overlay2  = "#6b7078",
                        overlay1  = "#565b63",
                        overlay0  = "#434850",
                        surface2  = ember.muted,
                        surface1  = "#262a2f",
                        surface0  = ember.overlay,
                        base      = ember.base,
                        mantle    = ember.surface,
                        crust     = "#050506",
                    },
                },
                integrations = {
                    treesitter       = true,
                    telescope        = { enabled = true },
                    lualine          = true,
                    gitsigns         = true,
                    mason            = true,
                    which_key        = true,
                    blink_cmp        = true,
                    native_lsp       = {
                        enabled = true,
                        underlines = {
                            errors      = { "undercurl" },
                            hints       = { "undercurl" },
                            warnings    = { "undercurl" },
                            information = { "undercurl" },
                        }
                    },
                    indent_blankline = { enabled = true, colored_indent_levels = false },
                    illuminate       = { enabled = true },
                    neotree          = true,
                    snacks           = true,
                },
                highlight_overrides = {
                    mocha = function(c)
                        return {
                            -- telescope - square box, no pane fill, terminal bg shows through
                            TelescopeNormal            = { bg = "NONE" },
                            TelescopePromptNormal      = { bg = "NONE" },
                            TelescopeResultsNormal     = { bg = "NONE" },
                            TelescopePreviewNormal     = { bg = "NONE" },
                            TelescopeBorder            = { bg = "NONE", fg = c.subtext1 },
                            TelescopePromptBorder      = { bg = "NONE", fg = c.subtext1 },
                            TelescopeResultsBorder     = { bg = "NONE", fg = c.subtext1 },
                            TelescopePreviewBorder     = { bg = "NONE", fg = c.subtext1 },
                            TelescopePromptTitle       = { bg = "NONE", fg = c.mauve },
                            TelescopeResultsTitle      = { bg = "NONE", fg = c.mauve },
                            TelescopePreviewTitle      = { bg = "NONE", fg = c.mauve },
                            TelescopeSelection         = { bg = c.surface0 },
                            TelescopeSelectionCaret    = { fg = c.mauve },
                            TelescopeMatching          = { fg = c.pink, style = { "bold" } },
                            -- floating windows (hover, signature, mason, lazy, which-key)
                            NormalFloat                = { bg = "NONE" },
                            FloatBorder                = { bg = "NONE", fg = c.overlay2 },
                            FloatTitle                 = { bg = "NONE", fg = c.mauve },
                            -- completion menu (blink.cmp)
                            Pmenu                      = { bg = "NONE" },
                            PmenuSel                   = { bg = c.surface0 },
                            BlinkCmpMenu               = { bg = "NONE" },
                            BlinkCmpMenuBorder         = { bg = "NONE", fg = c.overlay2 },
                            BlinkCmpDoc                = { bg = "NONE" },
                            BlinkCmpDocBorder          = { bg = "NONE", fg = c.overlay2 },
                            BlinkCmpSignatureHelp      = { bg = "NONE" },
                            BlinkCmpSignatureHelpBorder = { bg = "NONE", fg = c.overlay2 },
                            -- which-key, mason, lazy popups
                            WhichKeyNormal             = { bg = "NONE" },
                            WhichKeyBorder             = { bg = "NONE", fg = c.overlay2 },
                            WhichKeyFloat              = { bg = "NONE" },
                            MasonNormal                = { bg = "NONE" },
                            LazyNormal                 = { bg = "NONE" },
                            -- neo-tree panel, flat like an old file list
                            NeoTreeNormal              = { bg = "NONE" },
                            NeoTreeNormalNC            = { bg = "NONE" },
                            NeoTreeEndOfBuffer         = { bg = "NONE" },
                            NeoTreeWinSeparator        = { bg = "NONE", fg = c.surface2 },
                            -- tabline / winbar, flat
                            TabLine                    = { bg = "NONE" },
                            TabLineFill                = { bg = "NONE" },
                            TabLineSel                 = { bg = c.surface0, fg = c.mauve },
                            WinSeparator               = { bg = "NONE", fg = c.surface2 },
                            -- Cursor line / column subtle
                            CursorLine                 = { bg = c.mantle },
                            -- Diagnostics virtual text a touch dimmer
                            DiagnosticVirtualTextError = { fg = c.red, bg = "NONE" },
                            DiagnosticVirtualTextWarn  = { fg = c.yellow, bg = "NONE" },
                            DiagnosticVirtualTextHint  = { fg = c.teal, bg = "NONE" },
                            DiagnosticVirtualTextInfo  = { fg = c.sky, bg = "NONE" },
                        }
                    end,
                },
            })
            vim.cmd("colorscheme catppuccin-mocha")
            -- catch-all: some plugins (lazy-loaded popups especially) re-assert an
            -- opaque bg on their own highlight groups after the colorscheme loads,
            -- so clear them again here to keep the terminal bg showing through
            for _, g in ipairs({
                "WinBar", "WinBarNC",
                "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
                "StatusLine", "StatusLineNC",
                "TabLine", "TabLineFill",
                "Pmenu",
                "MasonNormal", "LazyNormal",
                "WhichKeyNormal", "WhichKeyFloat",
            }) do
                vim.api.nvim_set_hl(0, g, { bg = "NONE" })
            end
        end,
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local c = require("catppuccin.palettes").get_palette("mocha")

            -- transparent middle sections, coloured mode pill, star-accented
            local theme = {
                normal   = { a = { fg = ember.base, bg = c.mauve, gui = "bold" }, b = { fg = c.text, bg = "NONE" }, c = { fg = c.subtext0, bg = "NONE" } },
                insert   = { a = { fg = ember.base, bg = c.green, gui = "bold" }, b = { fg = c.text, bg = "NONE" }, c = { fg = c.subtext0, bg = "NONE" } },
                visual   = { a = { fg = ember.base, bg = c.flamingo, gui = "bold" }, b = { fg = c.text, bg = "NONE" }, c = { fg = c.subtext0, bg = "NONE" } },
                replace  = { a = { fg = ember.base, bg = c.pink, gui = "bold" }, b = { fg = c.text, bg = "NONE" }, c = { fg = c.subtext0, bg = "NONE" } },
                command  = { a = { fg = ember.base, bg = c.peach, gui = "bold" }, b = { fg = c.text, bg = "NONE" }, c = { fg = c.subtext0, bg = "NONE" } },
                inactive = { a = { fg = c.overlay0, bg = "NONE" }, b = { fg = c.overlay0, bg = "NONE" }, c = { fg = c.overlay0, bg = "NONE" } },
            }

            -- Show the active LSP client(s) in the statusline
            local function lsp_names()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if #clients == 0 then return "" end
                local names = {}
                for _, client in ipairs(clients) do
                    if client.name ~= "null-ls" then names[#names + 1] = client.name end
                end
                return " " .. table.concat(names, ", ")
            end

            require("lualine").setup({
                options = {
                    theme                = theme,
                    icons_enabled        = false,
                    -- plain pipes instead of powerline arrows - same separator polybar uses
                    component_separators = { left = "|", right = "|" },
                    section_separators   = { left = "", right = "" },
                    globalstatus         = true,
                    disabled_filetypes   = { statusline = { "dashboard", "snacks_dashboard" } },
                },
                sections = {
                    lualine_a = { { "mode", fmt = function(s) return "[" .. s:sub(1, 1) .. "]" end } },
                    lualine_b = {
                        { "branch" },
                        {
                            "diff",
                            symbols = { added = "+", modified = "~", removed = "-" },
                            diff_color = {
                                added    = { fg = c.green },
                                modified = { fg = c.yellow },
                                removed  = { fg = c.maroon },
                            },
                        },
                    },
                    lualine_c = {
                        { "filename", path = 1, symbols = { modified = "[+]", readonly = "[RO]", unnamed = "~" } },
                    },
                    lualine_x = {
                        {
                            "diagnostics",
                            sources = { "nvim_lsp" },
                            symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" },
                        },
                        { lsp_names, color = { fg = c.mauve } },
                        { "filetype", colored = true },
                    },
                    lualine_y = {},
                    lualine_z = {
                        { "location", fmt = function(s) return "Ln " .. s:gsub(":", ", Col ") end },
                        { "progress" },
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = { "neo-tree", "lazy", "mason" },
            })
        end,
    },

    -- transparent - strip bg from every group below so the terminal's own
    -- background (set in alacritty) always shows through
    {
        "xiyaowong/transparent.nvim",
        lazy = false,
        opts = {
            extra_groups = {
                "NormalFloat", "FloatBorder", "FloatTitle",
                "Pmenu", "PmenuSbar", "PmenuThumb",
                "BlinkCmpMenu", "BlinkCmpMenuBorder",
                "BlinkCmpDoc", "BlinkCmpDocBorder",
                "BlinkCmpSignatureHelp", "BlinkCmpSignatureHelpBorder",
                "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
                "TelescopeNormal", "TelescopeBorder",
                "WhichKeyNormal", "WhichKeyFloat", "WhichKeyBorder",
                "MasonNormal", "LazyNormal",
                "TabLine", "TabLineFill", "WinBar", "WinBarNC",
            },
        },
    },
}
