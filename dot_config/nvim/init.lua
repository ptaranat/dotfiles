-- Neovim configuration.
--
-- Rewritten from vimscript to Lua. It ran alongside the old config under a
-- separate NVIM_APPNAME for a while; that is over, and this is now the only
-- config. The vimscript version (.vimrc, .vim/, and the init.vim shim that
-- sourced it) is in the git history if any of it is ever wanted back.

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
