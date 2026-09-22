return {
	{
		"srcery-colors/srcery-vim",
		lazy = false,
		priority = 1000, -- load before everything else so nothing flashes
		config = function()
			-- newer srcery defaults italics on, keep them off
			vim.g.srcery_italic = 0

			vim.g.srcery_normal_float = 1

			vim.cmd.colorscheme("srcery")
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "srcery",
				globalstatus = true, -- one statusline, not one per split
				-- \u escapes: private-use glyphs get mangled when pasted
				section_separators = { left = "\u{E0B0}", right = "\u{E0B2}" },
				component_separators = { left = "\u{E0B1}", right = "\u{E0B3}" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					"branch",
					{ "diff", symbols = { added = "+", modified = "~", removed = "-" } },
					{ "filename", path = 0, symbols = { modified = " +", readonly = " ", newfile = " " } },
				},
				lualine_c = {},
				lualine_x = {
					"diagnostics",
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
						color = { fg = "#918175" }, -- srcery bright black, deliberately quiet
					},
				},
				lualine_y = { "location", "progress" },
				lualine_z = { "fileformat", "filetype" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { "filename", path = 0 } },
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
		},
	},

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

	{
		"HiPhish/rainbow-delimiters.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("rainbow-delimiters.setup").setup({})
		end,
	},

	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local dashboard = require("alpha.themes.dashboard")
			dashboard.section.buttons.val = {
				dashboard.button("e", "  New file", "<cmd>ene <BAR> startinsert<CR>"),
				dashboard.button("SPC f f", "  Find file", "<cmd>Telescope find_files<CR>"),
				dashboard.button("SPC f h", "  Recently opened", "<cmd>Telescope oldfiles<CR>"),
				dashboard.button("SPC f r", "  Frecent files", "<cmd>Telescope frecency<CR>"),
				dashboard.button("SPC f g", "  Find word", "<cmd>Telescope live_grep<CR>"),
				dashboard.button("SPC s l", "  Restore session", "<cmd>SessionManager load_last_session<CR>"),
				dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<CR>"),
				dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
			}
			require("alpha").setup(dashboard.config)
		end,
	},

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
