-- Colourscheme, statusline, bufferline, and the visual furniture.

return {
	-- srcery, matching the ghostty and tmux themes.
	{
		"srcery-colors/srcery-vim",
		lazy = false,
		priority = 1000, -- load before everything else so nothing flashes
		config = function()
			-- Italics off, matching how this looked before.
			--
			-- The old config set nothing beyond `colorscheme srcery` and got
			-- no italics, because that version of the plugin only enabled them
			-- under a GUI or with $TERM_ITALICS=true (unset here):
			--
			--   if has('gui_running') || $TERM_ITALICS ==? 'true'
			--     let g:srcery_italic=1
			--   else
			--     let g:srcery_italic=0
			--
			-- Newer srcery dropped that conditional and defaults to 1, so
			-- comments and keywords started rendering italic. Set explicitly
			-- rather than relying on either default.
			vim.g.srcery_italic = 0

			-- No colour overrides. The editor briefly rendered darker than the
			-- terminal because upstream srcery revised three colours in
			-- ba34fc5 (2025-08-09, "redesign background shades") -- background
			-- #1c1b19 -> #121110, white #baa67f -> #c5b088, bright black
			-- #918175 -> #917e6b -- while the ghostty theme still carried the
			-- older values. That is a deliberate contrast improvement by the
			-- author, not drift, so the ghostty theme was updated to match
			-- rather than pinning the plugin backwards here.

			-- Style floating windows. Off by default upstream, but this config
			-- is full of floats -- completion, telescope, which-key,
			-- diagnostics -- and without it they fall back to Normal and lose
			-- their border against the buffer behind them.
			vim.g.srcery_normal_float = 1

			vim.cmd.colorscheme("srcery")
		end,
	},

	-- lualine replaces lightline: same idea, native Lua, and it can show
	-- LSP and diagnostic state that lightline had no access to.
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		-- Section layout mirrors the old lightline config, which was:
		--   left  [mode, paste] [fugitive, readonly, filename, modified]
		--   right [ale] [lineinfo] [percent] [charcode, fileformat, filetype]
		-- Notably the filename was bare, not a path.
		opts = {
			options = {
				theme = "srcery",
				globalstatus = true, -- one statusline, not one per split
				section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					"branch",
					-- Added: +N ~N -N counts for the working tree. lightline's
					-- fugitive component only showed the branch name.
					{ "diff", symbols = { added = "+", modified = "~", removed = "-" } },
					{ "filename", path = 0, symbols = { modified = " +", readonly = " ", newfile = " " } },
				},
				lualine_c = {},
				lualine_x = {
					-- diagnostics stands in for the old ale section, and is
					-- populated by the LSP rather than a separate linter.
					"diagnostics",
					-- Added: which language servers are actually attached.
					-- The old setup gave no indication, so a server silently
					-- failing to start looked identical to one working.
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
			-- Buttons are labelled with the leader sequence that triggers them
			-- elsewhere in the config, the way the stock theme does, rather
			-- than with single letters that only work on this screen. The
			-- shortcut passed to button() is what alpha binds locally; the
			-- label is what you would type in a normal buffer.
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
