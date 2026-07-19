-- Keymaps ported from general.vim and plugin-settings.vim.
-- Plugin-specific maps live with their plugin spec instead.

local map = vim.keymap.set

-- Lazy shifting: ; enters command mode.
map("n", ";", ":", { desc = "Command mode" })

-- kj leaves insert/command mode.
map("i", "kj", "<Esc>", { desc = "Escape" })
map("c", "kj", "<C-c>", { desc = "Escape" })

-- Quicksave from any mode.
map("n", "<C-s>", "<cmd>update<CR>", { desc = "Save" })
map("i", "<C-s>", "<C-o><cmd>update<CR>", { desc = "Save" })
map("v", "<C-s>", "<C-c><cmd>update<CR>", { desc = "Save" })

-- Move the visual selection up and down, reindenting as it goes.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the cursor centred when jumping through search results and half-pages.
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Paste over a selection without clobbering the register.
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Yank to the system clipboard explicitly.
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })

-- Clear search highlight.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Window navigation without the <C-w> prefix.
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Resize windows.
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Grow window" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shrink window" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Narrow window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Widen window" })

-- Diagnostics.
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Buffers. The old config used barbar with Alt-, and Alt-. ; those bindings
-- are kept in the bufferline spec.
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Quickfix.
map("n", "<leader>co", "<cmd>copen<CR>", { desc = "Open quickfix" })
map("n", "<leader>cc", "<cmd>cclose<CR>", { desc = "Close quickfix" })
map("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>zz", { desc = "Previous quickfix" })
