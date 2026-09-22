local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.swapfile = false
opt.backup = false

opt.number = true
opt.relativenumber = true

opt.mouse = "a"
opt.hidden = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.showmatch = true
opt.title = true
opt.lazyredraw = false -- interacts badly with modern async plugins
opt.updatetime = 100
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true
opt.confirm = true -- prompt instead of failing when quitting unsaved

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.gdefault = true -- :s substitutes all occurrences without needing /g

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

opt.list = true
opt.listchars = {
	eol = "↴",
	tab = "→ ",
	nbsp = "␣",
	trail = "·",
	extends = "⟩",
	precedes = "⟨",
}

opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

opt.winblend = 10
opt.pumblend = 10
opt.wildoptions = "pum"

opt.completeopt = { "menuone", "noselect", "popup" }
opt.shortmess:append("I") -- no intro screen
opt.signcolumn = "yes" -- stop the gutter jumping when diagnostics appear
opt.termguicolors = true
opt.cursorline = true
opt.fileformats = { "unix", "dos" }

opt.history = 1000

if vim.fn.executable("rg") == 1 then
	opt.grepprg = "rg --vimgrep --smart-case --hidden"
	opt.grepformat = "%f:%l:%c:%m"
end
