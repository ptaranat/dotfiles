-- Git integration.

return {
	-- gitsigns replaces mhinz/vim-signify: same gutter marks, plus staging,
	-- blame and hunk navigation without leaving the buffer.
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			on_attach = function(buf)
				local gs = require("gitsigns")
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = "Git: " .. desc })
				end
				map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
				map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")
				map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
				map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
				map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
				map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
				map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
				map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
				map("n", "<leader>gd", gs.diffthis, "Diff this")
			end,
		},
	},

	-- fugitive, carried over. Nothing in the Lua ecosystem has replaced
	-- :Git for the less common operations.
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Gedit", "GBrowse" },
		keys = {
			{ "<leader>gg", "<cmd>Git<CR>", desc = "Git status" },
			{ "<leader>gl", "<cmd>Git log --oneline --graph --decorate<CR>", desc = "Git log" },
		},
	},

	-- Open the current line on the forge. Needed because :GBrowse relies on
	-- vim-rhubarb, which is not installed.
	{
		"linrongbin16/gitlinker.nvim",
		cmd = "GitLink",
		opts = {},
		keys = {
			{ "<leader>gy", "<cmd>GitLink<CR>", mode = { "n", "v" }, desc = "Copy git permalink" },
			{ "<leader>gY", "<cmd>GitLink!<CR>", mode = { "n", "v" }, desc = "Open git permalink" },
		},
	},
}
