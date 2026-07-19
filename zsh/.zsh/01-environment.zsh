# Paths. The (N-/) qualifier keeps an entry only when it is an existing
# directory, so anything uninstalled or moved drops out silently instead of
# accumulating in $PATH and being searched on every command.
path=(/opt/homebrew/bin(N-/) $path)
path=($HOME/.local/bin(N-/) $path)
path=($HOME/bin(N-/) $path)


# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
else
	export EDITOR='nvim'
fi

if [ -z "$SSH_AUTH_SOCK" ]; then
	eval "$(ssh-agent -s)" > /dev/null
	ssh-add ~/.ssh/id_rsa 2>/dev/null
fi

# Scroll in less
# export LESS='--mouse --wheel-lines=3 -r'

# Bat theme
export BAT_THEME=base16

# Notes directory
export NOTES_DIR=$HOME/Documents/notes

# Language
export LANG=en_US.UTF-8

# fzf + rg
export FZF_DEFAULT_COMMAND="rg --files --no-ignore --hidden --follow -g '!{.git,node_modules}/*' 2> /dev/null"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# fnm (node). Sourced only here; see the note in .zshrc about the fnm plugin.
eval "$(fnm env --version-file-strategy recursive --use-on-cd --shell zsh)"

# AWS
export AWS_SDK_LOAD_CONFIG=1
