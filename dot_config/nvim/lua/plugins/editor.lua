-- Editing, navigation and search.

return {
	-- Telescope, carried over from the old config with its bindings intact.
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				-- Native fzf sorter: the pure-Lua one is noticeably slower on
				-- large repos. Built with make, so it needs a compiler.
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			"nvim-telescope/telescope-frecency.nvim",
		},
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
			{ "<leader>fh", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
			{ "<leader>fr", "<cmd>Telescope frecency<CR>", desc = "Frecent files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
			{ "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
			{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
			{ "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
			{ "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
			{ "<leader>f:", "<cmd>Telescope command_history<CR>", desc = "Command history" },
		},
		opts = {
			defaults = {
				path_display = { "truncate" },
				sorting_strategy = "ascending",
				layout_config = { prompt_position = "top" },
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
						["<esc>"] = "close", -- one escape, not two
					},
				},
			},
			pickers = {
				find_files = { hidden = true },
			},
		},
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			pcall(telescope.load_extension, "fzf")
			pcall(telescope.load_extension, "frecency")
		end,
	},

	-- Comment toggling, replacing tpope/vim-commentary. Neovim 0.10+ ships
	-- gc/gcc natively, so this only adds treesitter-aware context for mixed
	-- files (JSX inside JS, script blocks in HTML).
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		event = "VeryLazy",
		opts = { enable_autocmd = false },
		config = function(_, opts)
			require("ts_context_commentstring").setup(opts)
			vim.g.skip_ts_context_commentstring_module = true
		end,
	},

	-- Surround text objects. The old config had nothing equivalent.
	{
		"kylechui/nvim-surround",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},

	-- Auto-close pairs, replacing Raimondi/delimitMate.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = { check_ts = true },
	},

	-- Detect indentation from the file, replacing tpope/vim-sleuth.
	{
		"NMAC427/guess-indent.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},

	-- Session management, carried over from Shatur/neovim-session-manager with
	-- the same bindings.
	{
		"Shatur/neovim-session-manager",
		lazy = false,
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>ss", "<cmd>SessionManager save_current_session<CR>", desc = "Save session" },
			{ "<leader>sl", "<cmd>SessionManager load_last_session<CR>", desc = "Load last session" },
			{ "<leader>sd", "<cmd>SessionManager delete_session<CR>", desc = "Delete session" },
		},
		config = function()
			require("session_manager").setup({
				-- Explicit, as before: never restore a session unasked.
				autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
			})
		end,
	},

	-- Jump anywhere on screen with two characters.
	{
		"folke/flash.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
			{ "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
		},
	},

	-- Supermaven, carried over from the old config.
	{
		"supermaven-inc/supermaven-nvim",
		event = "InsertEnter",
		opts = {
			keymaps = {
				accept_suggestion = "<C-y>",
				clear_suggestion = "<C-]>",
				accept_word = "<C-j>",
			},
		},
	},
}
