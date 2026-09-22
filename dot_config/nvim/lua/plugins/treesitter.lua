-- targets the main branch: there is no nvim-treesitter.configs

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
	-- no jsonc parser on main, json covers it
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

					local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(event.buf))
					if ok and stats and stats.size > 100 * 1024 then
						return
					end

					if pcall(vim.treesitter.start, event.buf, lang) then
						vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						vim.wo.foldmethod = "expr"
						vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					end
				end,
			})
		end,
	},

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
