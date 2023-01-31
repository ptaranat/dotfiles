# Aliases
alias reload="exec zsh"
alias e=$EDITOR
alias c="clear"
alias h="history -10"
alias hg="history | grep"
alias ZZ="exit"
alias py="python"
alias notes="cd $NOTES_DIR"
alias gcal="gcalcli"
alias week="gcalcli calw --noweekend --width=24 --color-now-marker brightblue"
alias agenda="gcalcli agenda --color-now-marker brightblue"
alias tfer="terraformer"
alias blue="_ systemctl restart bluetooth"
alias memo="bat -p ~/.memo.md"

# Yarn
alias yup="yarn up"
alias ywh="yarn why"

# Git
alias ghpr="gh pr create -w"
alias ghc="gh repo clone"
alias grum="git rebase upstream/main"

# Overrides
alias cp="cp -i"
alias mv="mv -i"
alias rmrf="rm -rf"

# Replace ls with exa
alias ls="exa"
alias l="exa --group-directories-first"
alias ll="exa -l --group-directories-first --git"
alias la="exa -la --group-directories-first --git"
alias lm="exa -ls modified --group-directories-first --reverse --git"
alias lmr="exa -ls modified --group-directories-first --git"

# Edit configs
alias zshrc="$EDITOR ~/.zshrc"
alias zshenv="$EDITOR ~/.zsh/01-environment.zsh"
alias zshalias="$EDITOR ~/.zsh/06-aliases.zsh"
alias zshrpg="$EDITOR ~/.zsh/07-rpg.zsh"
alias vimrc="$EDITOR ~/.vim/general.vim"
alias vimplug="$EDITOR ~/.vim/plugins.vim"
alias vimplugs="$EDITOR ~/.vim/plugin-settings.vim"
alias vimui="$EDITOR ~/.vim/ui.vim"

# Toys
alias weather="curl wttr.in"
alias disks='echo "╓───── m o u n t . p o i n t s"; \
			echo "╙────────────────────────────────────── ─ ─ "; \
			lsblk -a; echo ""; \
			echo "╓───── d i s k . u s a g e";\
			echo "╙────────────────────────────────────── ─ ─ "; \
			df -h;'

# Recursively convert line endings to Unix
alias fixdos="find . -type f -print0 | xargs -0 dos2unix"

# Update cargo packages using cargo-update
alias cargoupdate="cargo install-update -a"

# Kubectl-argo-rollouts
alias kar="kubectl-argo-rollouts"

# Files
alias -s md="glow -p"

# Search for aliases
function what() {
	if [ "$1" != "" ]
	then
		alias | grep --color=always "$1" | bat
	else
		alias | bat
	fi
}

# Make folder then cd
function mcd() {
	if [ "$1" != "" ]
	then
		mkdir -p $1 ; cd $1
	else
		echo "Missing folder name"
	fi
}

function note() {
	if [ -n "$1" ]; then
		$EDITOR "$NOTES_DIR/$1.md"
	else
		timestamp=$(date -u +"%Y-%m-%d")
		filename="$NOTES_DIR/$timestamp.md"
		$EDITOR "$filename"
	fi
}

