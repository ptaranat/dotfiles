# Paths
path=($(go env GOPATH)/bin $path)
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
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# AWS
export AWS_PROFILE=admin-lab
export AWS_DEFAULT_REGION=us-east-1

# NVM
export NVM_LAZY_LOAD=true
export NVM_NO_USE=true
