local o = vim.opt

-- Line numbers
o.number = true
o.relativenumber = true

-- Indentation
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true

-- Search
o.ignorecase = true
o.smartcase = true
o.hlsearch = false
o.incsearch = true

-- UI
o.termguicolors = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 8
o.sidescrolloff = 8
o.wrap = false
o.splitright = true
o.splitbelow = true
o.showmode = false

-- Files
o.undofile = true
o.swapfile = false
o.backup = false
o.updatetime = 250

-- Completion
o.completeopt = { "menuone", "noselect" }

-- Clipboard
o.clipboard = "unnamedplus"
