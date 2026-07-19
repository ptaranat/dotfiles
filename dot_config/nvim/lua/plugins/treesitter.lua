-- Treesitter: syntax highlighting, indentation and structural text objects.
--
-- Written against nvim-treesitter's `main` branch, the 1.0 rewrite. That
-- branch dropped `nvim-treesitter.configs` entirely: there is no longer a
-- setup table with highlight/indent/textobject sub-tables. Parsers are
-- installed imperatively with .install(), and highlighting is started per
-- buffer via vim.treesitter.start() from a FileType autocommand.
--
-- The old vimscript config had effectively arrived at the same place, calling
-- pcall(vim.treesitter.start) from a FileType autocommand -- it just did not
-- get indentation or text objects out of it.

local parsers = {
	"bash",
	"c",
	"css",
	"diff",
	"dockerfile",
	"gitcommit",
	"gitignore",
	"gleam",
	"go",
	"gomod",
	"hcl",
	"html",
	"javascript",
	-- jsonc is not a separate parser on this branch; the json parser covers it
	"json",
	"lua",
	"luadoc",
	"make",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"regex",
	"rust",
	"terraform",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter").setup()

			-- Install anything missing, without blocking startup.
			local installed = require("nvim-treesitter.config").get_installed("parsers")
			local missing = vim.tbl_filter(function(p)
				return not vim.tbl_contains(installed, p)
			end, parsers)
			if #missing > 0 then
				require("nvim-treesitter").install(missing)
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("cfg_treesitter", { clear = true }),
				callback = function(event)
					local ft = vim.bo[event.buf].filetype
					local lang = vim.treesitter.language.get_lang(ft)
					if not lang then
						return
					end

					-- Skip large files: parsing is fast but not free.
					local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(event.buf))
					if ok and stats and stats.size > 100 * 1024 then
						return
					end

					-- start() fails when the parser is not installed yet, which
					-- is expected on first run while .install() is still going.
					if pcall(vim.treesitter.start, event.buf, lang) then
						vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						-- Treesitter-aware folds, still closed on open by
						-- foldlevel=99 in options.lua.
						vim.wo.foldmethod = "expr"
						vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					end
				end,
			})
		end,
	},

	-- Structural text objects. Also on `main`, with a new select/move API that
	-- takes the query directly rather than a keymap table.
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select").select_textobject
			local move = require("nvim-treesitter-textobjects.move")
			local map = vim.keymap.set

			for lhs, query in pairs({
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
			}) do
				map({ "x", "o" }, lhs, function()
					select(query, "textobjects")
				end, { desc = "Textobject " .. query })
			end

			map({ "n", "x", "o" }, "]f", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function" })
			map({ "n", "x", "o" }, "[f", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Previous function" })
			map({ "n", "x", "o" }, "]c", function()
				move.goto_next_start("@class.outer", "textobjects")
			end, { desc = "Next class" })
			map({ "n", "x", "o" }, "[c", function()
				move.goto_previous_start("@class.outer", "textobjects")
			end, { desc = "Previous class" })
		end,
	},
}
