return {
	{
		"gleam-lang/gleam.vim",
		ft = "gleam",
	},

	{
		"Olical/conjure",
		ft = { "clojure", "fennel", "python", "lua" },
		init = function()
			-- stop conjure auto-starting a REPL in lua/python buffers
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

	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
}
