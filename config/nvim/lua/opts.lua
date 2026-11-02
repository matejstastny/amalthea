local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2

opt.scrolloff = 8
opt.termguicolors = true
opt.signcolumn = "yes"
opt.clipboard = "unnamedplus"
opt.undofile = true

opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true

opt.wrap = true
opt.whichwrap = "b,s,h,l,<,>,[,]"
opt.cursorline = true

if vim.g.neovide then
    -- no blur, no particle trails, no smooth-scroll - snap like an old editor
    vim.g.neovide_opacity = 1.0
    vim.g.neovide_scroll_animation_length = 0.0
    vim.g.neovide_cursor_animate_in_insert_mode = false
    vim.g.neovide_cursor_animation_length = 0.0
    vim.o.guifont = "DankMono Nerd Font Mono:h16"
end
