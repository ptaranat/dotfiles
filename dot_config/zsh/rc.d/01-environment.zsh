# PATH is set in .zshenv, not here, so non-interactive shells get it too.

# nvim everywhere. No vim fallback over SSH: the config is Lua now, so vim
# would give an unconfigured editor rather than a familiar one.
export EDITOR='nvim'
export VISUAL=$EDITOR

if [ -z "$SSH_AUTH_SOCK" ]; then
	eval "$(ssh-agent -s)" > /dev/null
	ssh-add ~/.ssh/id_rsa 2>/dev/null
fi

# --mouse is required for wheel scrolling, including in delta, which shells out
# to less. -R passes colour only; -F skips the pager for one-screen output.
export LESS='--mouse --wheel-lines=3 -RF'

export BAT_THEME=base16
export NOTES_DIR=$HOME/Documents/notes
export LANG=en_US.UTF-8

export FZF_DEFAULT_COMMAND="rg --files --no-ignore --hidden --follow -g '!{.git,node_modules}/*' 2> /dev/null"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Keeps churn in Downloads out of the zoxide index. $HOME is repeated because
# setting this replaces zoxide's default (which is $HOME) rather than adding to
# it; [Dd] because the globs are case-sensitive but macOS filesystems are not.
export _ZO_EXCLUDE_DIRS="$HOME:$HOME/[Dd]ownloads:$HOME/[Dd]ownloads/**"

export AWS_SDK_LOAD_CONFIG=1
