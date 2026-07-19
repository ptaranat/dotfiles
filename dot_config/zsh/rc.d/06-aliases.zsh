# Aliases
alias reload="exec zsh"
# A function, not `alias e=$EDITOR`: an alias expands its right-hand side once,
# at definition time, so it would freeze whichever editor $EDITOR held when this
# file was sourced rather than following it.
e() { ${EDITOR:-nvim} "$@" }
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
alias cl="claude"

# attach/create a tmux session by name, or fzf-pick one; bare tm on an empty server -> main
tm() {
  local change target="$1"
  [[ -n "$TMUX" ]] && change=switch-client || change=attach-session
  if [[ -z "$target" ]]; then
    if [[ -n "$(tmux list-sessions 2>/dev/null)" ]]; then
      target=$(tmux list-sessions -F '#{session_name}' | fzf --exit-0) || return  # esc cancels
      [[ -z "$target" ]] && return
    else
      target=main
    fi
  fi
  tmux "$change" -t "$target" 2>/dev/null || { tmux new-session -d -s "$target" && tmux "$change" -t "$target"; }
}

# Git
alias ghpr="gh pr create -w"
alias ghc="gh repo clone"
alias grum="git rebase upstream/main"

# Overrides
alias cp="cp -i"
alias mv="mv -i"
alias rmrf="rm -rf"

# Replace ls with eza
alias ls="eza"
alias l="eza --group-directories-first"
alias ll="eza -l --group-directories-first --git"
alias la="eza -la --group-directories-first --git"
alias lm="eza -ls modified --group-directories-first --reverse --git"
alias lmr="eza -ls modified --group-directories-first --git"

# Neovim
alias lazy="nvim +Lazy"
alias health="nvim +checkhealth"

# chezmoi
alias cm="chezmoi"
alias cma="chezmoi apply"
alias cmd="chezmoi diff"
alias cme="chezmoi edit --apply"     # edit the source and write it out in one step
alias cmu="chezmoi update"           # pull, then apply
alias cms="chezmoi status"
alias cmcd='cd "$(chezmoi source-path)"'
# Pull a change made directly to a deployed file back into the source.
alias cmadd="chezmoi add"

# Edit configs. These go through `chezmoi edit` rather than opening the
# deployed file: editing the target directly works until the next
# `chezmoi apply` silently overwrites it. --apply writes the change straight
# out, so the two stay in step.
alias zshrc="chezmoi edit --apply ${ZDOTDIR:-$HOME/.config/zsh}/.zshrc"
alias zshenv="chezmoi edit --apply ${ZDOTDIR:-$HOME/.config/zsh}/rc.d/01-environment.zsh"
alias zshalias="chezmoi edit --apply ${ZDOTDIR:-$HOME/.config/zsh}/rc.d/06-aliases.zsh"
alias zshrpg="chezmoi edit --apply ${ZDOTDIR:-$HOME/.config/zsh}/rc.d/07-rpg.zsh"
alias zshprompt="chezmoi edit --apply ${ZDOTDIR:-$HOME/.config/zsh}/prompt/overrides.zsh"
alias nvimrc="chezmoi edit --apply ~/.config/nvim/init.lua"
alias nvimopts="chezmoi edit --apply ~/.config/nvim/lua/config/options.lua"
alias nvimkeys="chezmoi edit --apply ~/.config/nvim/lua/config/keymaps.lua"
alias nvimplug="chezmoi edit --apply ~/.config/nvim/lua/plugins/ui.lua"
alias gitconfig="chezmoi edit --apply ~/.gitconfig"
alias brewfile="$EDITOR \"$(chezmoi source-path)/Brewfile\""

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

# Markedit
markedit() {
	if [ -t 0 ]; then
		open -a Markedit "$@"
	else
		local f="$(mktemp -d -t dw)/note.md"
		cat > "$f"
		open -a Markedit "$f"
	fi
}
