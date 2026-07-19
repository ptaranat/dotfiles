-- Neovim configuration, Lua rewrite of the previous vimscript setup.
--
-- Runs under its own NVIM_APPNAME so it can be developed alongside the old
-- config rather than replacing it:
--
--     nvim                  the existing vimscript config (~/.config/nvim)
--     NVIM_APPNAME=nvim-lua nvim    this one, aliased to `v`
--
-- Once this proves itself, ~/.config/nvim can be replaced by it and the alias
-- dropped. Nothing here touches the old config.

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
