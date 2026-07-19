-- Editor settings, ported from the old general.vim.
--
-- Neovim 0.12 already defaults a lot of what the old config set explicitly
-- (nocompatible, syntax on, filetype plugin indent on, incsearch, wildmenu,
-- backspace, laststatus=2, encoding=utf-8), so those are gone rather than
-- restated.

local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Undo history that survives restarts. Under its own appname so it does not
-- share state with the old config's ~/.vim/undo.
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.swapfile = false
opt.backup = false

-- Hybrid line numbers: absolute on the cursor line, relative elsewhere.
-- The insert-mode toggle lives in autocmds.lua.
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

-- Searching: case-insensitive unless the pattern contains a capital.
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.gdefault = true -- :s substitutes all occurrences without needing /g

-- Indentation: four spaces. vim-sleuth's successor (guess-indent) overrides
-- this per file when a project disagrees.
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

-- Show whitespace that would otherwise be invisible.
opt.list = true
opt.listchars = {
	eol = "↴",
	tab = "→ ",
	nbsp = "␣",
	trail = "·",
	extends = "⟩",
	precedes = "⟨",
}

-- Folds available but closed by nothing on open.
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

opt.completeopt = { "menuone", "noselect", "popup" }
opt.shortmess:append("I") -- no intro screen
opt.signcolumn = "yes" -- stop the gutter jumping when diagnostics appear
opt.termguicolors = true
opt.cursorline = true
opt.fileformats = { "unix", "dos" }

-- Persist more than the default; the old config kept none of this.
opt.history = 1000

-- Ripgrep for :grep, matching the shell setup.
if vim.fn.executable("rg") == 1 then
	opt.grepprg = "rg --vimgrep --smart-case --hidden"
	opt.grepformat = "%f:%l:%c:%m"
end
