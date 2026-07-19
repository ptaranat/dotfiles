-- LSP, formatting and linting.
--
-- The old config configured terraformls and gleam by hand via vim.lsp.config
-- and formatted on save with vim.lsp.buf.format() in filetype autocommands.
-- That approach still works and is kept, but mason installs the servers rather
-- than requiring each to be on $PATH already, and conform handles formatting
-- so a project's own prettier/ruff is preferred over whatever the LSP does.

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
		},
		config = function()
			-- Diagnostics: virtual text off by default because it pushes code
			-- around; the float on <leader>e shows the detail instead.
			vim.diagnostic.config({
				virtual_text = false,
				severity_sort = true,
				float = { border = "rounded", source = true },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = " ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			})

			-- Buffer-local maps, set only where a server actually attached.
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("cfg_lsp_attach", { clear = true }),
				callback = function(event)
					local map = function(keys, fn, desc)
						vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					map("gd", vim.lsp.buf.definition, "Definition")
					map("gr", vim.lsp.buf.references, "References")
					map("gI", vim.lsp.buf.implementation, "Implementation")
					map("gD", vim.lsp.buf.declaration, "Declaration")
					map("K", vim.lsp.buf.hover, "Hover")
					map("<leader>lr", vim.lsp.buf.rename, "Rename")
					map("<leader>la", vim.lsp.buf.code_action, "Code action")
					map("<leader>ld", vim.lsp.buf.type_definition, "Type definition")

					-- Highlight other references to the symbol under the cursor.
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method("textDocument/documentHighlight") then
						local hl = vim.api.nvim_create_augroup("cfg_lsp_highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = hl,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = hl,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end,
			})

			-- Servers mason should keep installed. gleam is deliberately absent:
			-- its LSP ships inside the gleam binary itself (installed via brew),
			-- so mason has nothing to fetch.
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"ts_ls",
					"pyright",
					"gopls",
					"terraformls",
					"bashls",
					"jsonls",
					"yamlls",
				},
				automatic_installation = true,
			})

			-- lua_ls needs to be told it is editing neovim config, or every
			-- `vim.` reference is flagged undefined.
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = { checkThirdParty = false },
						diagnostics = { globals = { "vim" } },
						telemetry = { enable = false },
					},
				},
			})

			-- gleam, as in the old config: the language server is a subcommand
			-- of the gleam binary.
			vim.lsp.config("gleam", {
				cmd = { "gleam", "lsp" },
				filetypes = { "gleam" },
				root_markers = { "gleam.toml", ".git" },
			})
			vim.lsp.enable("gleam")
		end,
	},

	-- Formatting. Prefers a project's own formatter over the LSP, which is
	-- what the old `vim.lsp.buf.format()` on save could not do.
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>lf",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				desc = "Format buffer",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format", "ruff_organize_imports" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				go = { "gofmt" },
				sh = { "shfmt" },
				terraform = { "terraform_fmt" },
				tf = { "terraform_fmt" },
				hcl = { "terraform_fmt" },
			},
			format_on_save = function(bufnr)
				-- gleam and terraform formatted on save, as before. Everything
				-- else is explicit, so a shared repo's style is not silently
				-- rewritten on open-and-save.
				local auto = { gleam = true, terraform = true, tf = true, hcl = true, lua = true }
				if not auto[vim.bo[bufnr].filetype] then
					return nil
				end
				return { timeout_ms = 2000, lsp_format = "fallback" }
			end,
		},
	},

	-- Linting for tools that are not language servers, replacing w0rp/ale.
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				zsh = { "shellcheck" },
				terraform = { "tflint" },
				python = { "ruff" },
			}
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("cfg_lint", { clear = true }),
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
