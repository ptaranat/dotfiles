# Paths
path=(/opt/homebrew/bin $path)
path=($HOME/.local/bin $path)
path=($HOME/bin $path)
path=($PYENV_ROOT/bin $path)
path=($HOME/Library/Python/3.9/bin $path)


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

# Python
export PYTHONPATH="/opt/homebrew/bin/python3"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# fzf + rg
export FZF_DEFAULT_COMMAND="rg --files --no-ignore --hidden --follow -g '!{.git,node_modules}/*' 2> /dev/null"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# NVM
# export NVM_LAZY_LOAD=true
# export NVM_NO_USE=true

# FNM
eval "$(fnm env --version-file-strategy recursive --use-on-cd --shell zsh)"
# export ZSH_FNM_NODE_VERSION="24"

# AWS
export AWS_SDK_LOAD_CONFIG=1
