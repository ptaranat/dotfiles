# Paths. The (N-/) qualifier keeps an entry only when it is an existing
# directory, so anything uninstalled or moved drops out silently instead of
# accumulating in $PATH and being searched on every command.
# ~/.local/bin is added in .zshenv so non-interactive shells get it too.
path=(/opt/homebrew/bin(N-/) $path)
path=($HOME/bin(N-/) $path)

# nvim everywhere. This used to fall back to vim over SSH, from when the config
# was vimscript and worked in both; it is Lua now and vim cannot read it, so
# the fallback would have meant an unconfigured editor rather than a familiar
# one.
export EDITOR='nvim'
export VISUAL=$EDITOR

if [ -z "$SSH_AUTH_SOCK" ]; then
	eval "$(ssh-agent -s)" > /dev/null
	ssh-add ~/.ssh/id_rsa 2>/dev/null
fi

# Bat theme
export BAT_THEME=base16

# Notes directory
export NOTES_DIR=$HOME/Documents/notes

# Language
export LANG=en_US.UTF-8

# fzf + rg
export FZF_DEFAULT_COMMAND="rg --files --no-ignore --hidden --follow -g '!{.git,node_modules}/*' 2> /dev/null"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Node, Python and friends are managed by mise, activated in .zshrc. It
# replaced fnm here and pyenv before that. uv is kept for Python packaging:
# mise handles interpreter versions, uv handles dependencies and venvs, and
# mise will use uv to build venvs when it finds it.
export AWS_SDK_LOAD_CONFIG=1
