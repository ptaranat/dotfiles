-- Language-specific plugins that the LSP does not cover.
--
-- Most of the old config's language plugins are gone rather than ported:
-- vim-go, hashivim/vim-terraform and psf/black all predate having a working
-- LSP for those languages. gopls, terraformls and ruff now do that work, and
-- formatting is handled by conform.

return {
	-- Gleam has no treesitter-driven filetype detection built in, and the
	-- language is new enough that neovim does not ship a ftplugin for it.
	{
		"gleam-lang/gleam.vim",
		ft = "gleam",
	},

	-- Conjure, carried over from the old config for Clojure REPL work, along
	-- with the dispatch plumbing it needs to start a REPL.
	{
		"Olical/conjure",
		ft = { "clojure", "fennel", "python", "lua" },
		init = function()
			-- Off by default: it otherwise starts a REPL for every supported
			-- filetype, which is unwanted in Lua and Python buffers.
			vim.g["conjure#mapping#doc_word"] = "gk"
			vim.g["conjure#filetype#lua"] = false
			vim.g["conjure#filetype#python"] = false
		end,
		dependencies = {
			{ "tpope/vim-dispatch", cmd = { "Dispatch", "Make", "Focus", "Start" } },
			{ "clojure-vim/vim-jack-in", cmd = { "Clj", "Lein", "Boot" } },
			{ "radenling/vim-dispatch-neovim" },
		},
	},

	-- Markdown preview without leaving the editor.
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
}
