-- lazy.nvim bootstrap. Replaces vim-plug.
--
-- lazy clones itself on first run, so a fresh machine needs nothing beyond
-- neovim and git. Plugin specs live in lua/plugins/*.lua and are picked up
-- automatically by the import below.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},
	install = { colorscheme = { "srcery", "habamax" } },
	checker = {
		-- Check for updates but never apply them unprompted.
		enabled = true,
		notify = false,
	},
	change_detection = { notify = false },
	performance = {
		rtp = {
			-- Disable built-in plugins that are either superseded or unused.
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
				"netrwPlugin",
			},
		},
	},
})
