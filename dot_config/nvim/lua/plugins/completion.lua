-- Completion and snippets.
--
-- blink.cmp replaces the nvim-cmp + cmp-nvim-lsp + cmp-buffer + cmp-path +
-- cmp-vsnip + vim-vsnip + vim-vsnip-integ stack from the old config: one
-- plugin instead of seven, with a Rust fuzzy matcher rather than a Lua one.
-- friendly-snippets is kept, since blink reads the same snippet format.

return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		version = "*", -- release tag ships the prebuilt fuzzy binary
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				-- Decoupled so the keys used for plain editing are never stolen
				-- by the auto-popup: Tab only jumps snippets/indents, Enter only
				-- makes a newline unless an item was deliberately selected. Menu
				-- navigation is explicit on C-n/C-p; C-Space toggles, C-e aborts,
				-- C-d/C-f scroll the docs.
				preset = "none",
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<C-n>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<Tab>"] = { "snippet_forward", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },
				["<C-d>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
			},
			appearance = { nerd_font_variant = "mono" },
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = false }, -- supermaven owns the inline text
				-- Nothing preselected, so <CR> only accepts after C-n/C-p.
				list = { selection = { preselect = false, auto_insert = false } },
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			-- Lua fallback if the prebuilt binary is unavailable for the
			-- platform, rather than failing to load entirely.
			fuzzy = { implementation = "prefer_rust_with_warning" },
			signature = { enabled = true },
		},
		opts_extend = { "sources.default" },
	},
}
