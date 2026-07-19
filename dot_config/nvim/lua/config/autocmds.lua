-- Autocommands ported from general.vim.

local augroup = function(name)
	return vim.api.nvim_create_augroup("cfg_" .. name, { clear = true })
end

-- Relative numbers only where they are useful: absolute while typing, and in
-- windows that do not have focus.
local numbertoggle = augroup("numbertoggle")
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
	group = numbertoggle,
	callback = function()
		if vim.wo.number and vim.api.nvim_get_mode().mode ~= "i" then
			vim.wo.relativenumber = true
		end
	end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
	group = numbertoggle,
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = false
		end
	end,
})

-- Briefly highlight whatever was just yanked. Replaces having to guess what
-- the last operation covered.
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.hl.on_yank({ timeout = 150 })
	end,
})

-- Strip trailing whitespace on save. The old config did this via a setline()
-- map over the whole buffer for a fixed filetype list; this preserves the
-- cursor position and applies everywhere except filetypes where trailing
-- whitespace is meaningful.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("trim_whitespace"),
	callback = function(event)
		if vim.bo[event.buf].filetype == "markdown" then
			return -- two trailing spaces is a hard line break
		end
		if not vim.bo[event.buf].modifiable then
			return
		end
		local save = vim.fn.winsaveview()
		vim.cmd([[keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(save)
	end,
})

-- Start git commit messages in insert mode, and enable spell checking for
-- prose filetypes.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("prose"),
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.wrap = true
		vim.opt_local.complete:append("kspell")
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("gitcommit_insert"),
	pattern = "gitcommit",
	callback = function()
		vim.cmd("startinsert")
	end,
})

-- Reopen a file at the position it was left.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_position"),
	callback = function(event)
		local exclude = { "gitcommit", "gitrebase" }
		if vim.tbl_contains(exclude, vim.bo[event.buf].filetype) then
			return
		end
		local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
		local lcount = vim.api.nvim_buf_line_count(event.buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Close throwaway windows with plain q.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = { "help", "qf", "man", "lspinfo", "checkhealth", "startuptime" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

-- Create missing parent directories when writing a new file.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("auto_mkdir"),
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return -- not a real path (scp://, oil://, ...)
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})
