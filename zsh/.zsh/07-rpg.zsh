# source /Users/panat/projects/rpg/roll/bash_completion/roll
znap install matteocorti/roll
source ~[roll]/bash_completion/roll

# Use uv script for dice rolling
alias dice='uv run ~/.dotfiles/zsh/.zsh/rpg.py dice'
alias thaco='uv run ~/.dotfiles/zsh/.zsh/rpg.py thaco'
