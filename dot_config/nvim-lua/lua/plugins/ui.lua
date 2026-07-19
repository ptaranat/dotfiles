-- Colourscheme, statusline, bufferline, and the visual furniture.

return {
	-- srcery, matching the ghostty and tmux themes.
	{
		"srcery-colors/srcery-vim",
		lazy = false,
		priority = 1000, -- load before everything else so nothing flashes
		config = function()
			vim.g.srcery_italic = 1
			vim.g.srcery_transparent_background = 0
			vim.cmd.colorscheme("srcery")
		end,
	},

	-- lualine replaces lightline: same idea, native Lua, and it can show
	-- LSP and diagnostic state that lightline had no access to.
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "srcery",
				globalstatus = true, -- one statusline, not one per split
				section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" },
			},
			sections = {
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { { "filename", path = 1 } },
				lualine_x = {
					-- Which LSP servers are actually attached, which the old
					-- setup gave no indication of.
					{
						function()
							local clients = vim.lsp.get_clients({ bufnr = 0 })
							if #clients == 0 then
								return ""
							end
							local names = vim.tbl_map(function(c)
								return c.name
							end, clients)
							return " " .. table.concat(names, ",")
						end,
					},
					"encoding",
					"filetype",
				},
			},
		},
	},

	-- bufferline replaces barbar. The Alt-, / Alt-. / Alt-<n> bindings are
	-- carried over unchanged.
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				diagnostics = "nvim_lsp",
				separator_style = "slant",
				offsets = {
					{ filetype = "neo-tree", text = "Explorer", separator = true },
				},
			},
		},
		keys = {
			{ "<A-,>", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
			{ "<A-.>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
			{ "<A-<>", "<cmd>BufferLineMovePrev<CR>", desc = "Move buffer left" },
			{ "<A->>", "<cmd>BufferLineMoveNext<CR>", desc = "Move buffer right" },
			{ "<A-1>", "<cmd>BufferLineGoToBuffer 1<CR>", desc = "Buffer 1" },
			{ "<A-2>", "<cmd>BufferLineGoToBuffer 2<CR>", desc = "Buffer 2" },
			{ "<A-3>", "<cmd>BufferLineGoToBuffer 3<CR>", desc = "Buffer 3" },
			{ "<A-4>", "<cmd>BufferLineGoToBuffer 4<CR>", desc = "Buffer 4" },
			{ "<A-5>", "<cmd>BufferLineGoToBuffer 5<CR>", desc = "Buffer 5" },
			{ "<A-6>", "<cmd>BufferLineGoToBuffer 6<CR>", desc = "Buffer 6" },
			{ "<A-7>", "<cmd>BufferLineGoToBuffer 7<CR>", desc = "Buffer 7" },
			{ "<A-8>", "<cmd>BufferLineGoToBuffer 8<CR>", desc = "Buffer 8" },
			{ "<A-9>", "<cmd>BufferLineGoToBuffer 9<CR>", desc = "Buffer 9" },
			{ "<A-0>", "<cmd>BufferLineGoToBuffer -1<CR>", desc = "Last buffer" },
		},
	},

	-- Indent guides. indent-blankline v3 is a rewrite with a different API to
	-- the version the old config used.
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			indent = { char = "│" },
			scope = { enabled = true, show_start = false, show_end = false },
			exclude = {
				filetypes = { "help", "alpha", "dashboard", "lazy", "mason", "checkhealth" },
			},
		},
	},

	-- Rainbow delimiters, replacing luochen1990/rainbow. This one is
	-- treesitter-driven, so it understands the language rather than counting
	-- brackets.
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("rainbow-delimiters.setup").setup({})
		end,
	},

	-- Start screen, replacing alpha-nvim.
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local dashboard = require("alpha.themes.dashboard")
			dashboard.section.buttons.val = {
				dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
				dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
				dashboard.button("g", "  Grep", "<cmd>Telescope live_grep<CR>"),
				dashboard.button("s", "  Restore session", "<cmd>SessionManager load_last_session<CR>"),
				dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<CR>"),
				dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
			}
			require("alpha").setup(dashboard.config)
		end,
	},

	-- Shows the pending keymap sequence. Nothing in the old config did this,
	-- and it makes a leader-driven setup discoverable.
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			spec = {
				{ "<leader>f", group = "find" },
				{ "<leader>g", group = "git" },
				{ "<leader>l", group = "lsp" },
				{ "<leader>s", group = "session" },
				{ "<leader>c", group = "quickfix" },
				{ "<leader>b", group = "buffer" },
			},
		},
	},

	-- File explorer. The old config had none; netrw is disabled in lazy.lua.
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{ "<leader>fe", "<cmd>Neotree toggle<CR>", desc = "File explorer" },
		},
		opts = {
			filesystem = {
				follow_current_file = { enabled = true },
				hijack_netrw_behavior = "open_current",
			},
		},
	},
}
