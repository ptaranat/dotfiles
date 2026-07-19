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
				-- Mirrors the old nvim-cmp mapping so the muscle memory holds:
				-- Tab/S-Tab cycle, C-Space opens, CR confirms, C-e aborts,
				-- C-d/C-f scroll the docs.
				preset = "none",
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
				["<C-d>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
			},
			appearance = { nerd_font_variant = "mono" },
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = false }, -- supermaven owns the inline text
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
