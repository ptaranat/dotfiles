# fzf-tab: previews while tab-completing. These zstyles decide what shows in the
# preview pane per command. zsh tags candidates with a group name ("modified
# file", "recent commit object name"), which is what the git dispatch below
# keys off via $group.

# Preview panes need colour from tools that would otherwise detect a pipe.
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border
# Accept the current selection with a single keypress rather than enter-only.
zstyle ':fzf-tab:*' continuous-trigger '/'
# Show a scrollable preview rather than truncating.
zstyle ':fzf-tab:*' fzf-preview-window 'right:55%:wrap'

# Directories: list contents rather than showing nothing.
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null | head -50'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null | head -50'
zstyle ':fzf-tab:complete:j:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null | head -50'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null | head -50'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null | head -50'

# Files: syntax-highlighted head, falling back to a directory listing.
for _cmd in bat cat nvim vim nano rm cp mv; do
	zstyle ":fzf-tab:complete:${_cmd}:*" fzf-preview \
		'if [[ -d $realpath ]]; then eza -1 --color=always --icons $realpath | head -50; else bat --style=numbers --color=always --line-range=:100 $realpath 2>/dev/null || head -100 $realpath; fi'
done
unset _cmd

# git: the payload depends on what kind of candidate is under the cursor, so
# branch on the completion group. delta renders the diffs.
zstyle ':fzf-tab:complete:git-(add|diff|restore|checkout|switch|stash):*' fzf-preview \
	'case "$group" in
	"modified file") git diff --color=always -- $word | delta 2>/dev/null || git diff --color=always -- $word ;;
	"recent commit object name") git show --color=always $word | delta 2>/dev/null || git show --color=always $word ;;
	"branch"|"local head"|"remote head") git log --oneline --graph --color=always -20 $word ;;
	*) git log --oneline --graph --color=always -20 $word 2>/dev/null || eza -1 --color=always $realpath ;;
	esac'

zstyle ':fzf-tab:complete:git-(log|show|rebase|revert|cherry-pick):*' fzf-preview \
	'git show --color=always $word 2>/dev/null | delta 2>/dev/null || git log --oneline --color=always -20 $word 2>/dev/null'

# Environment variables: show the value, not just the name.
zstyle ':fzf-tab:complete:(-command-|export|unset|printenv):*' fzf-preview \
	'echo ${(P)word}'

# systemctl-alikes and process control.
zstyle ':fzf-tab:complete:kill:*' fzf-preview \
	'ps -p $word -o pid=,user=,%cpu=,%mem=,command= 2>/dev/null'

# chezmoi: show what applying would change for the file under the cursor.
zstyle ':fzf-tab:complete:chezmoi:*' fzf-preview \
	'chezmoi diff $word 2>/dev/null | head -100'

# mise: what a tool resolves to.
zstyle ':fzf-tab:complete:mise:*' fzf-preview \
	'mise ls $word 2>/dev/null | head -30'

# brew: package descriptions without leaving the prompt.
zstyle ':fzf-tab:complete:brew-(install|info|uninstall|reinstall):*' fzf-preview \
	'brew info $word 2>/dev/null | head -40'

# Completion behaviour: case-insensitive, then partial-word, then substring.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# Colour the completion list the same way ls does.
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Group results under their category headings, which is what $group keys off.
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
# Do not offer files already on the command line.
zstyle ':completion:*' ignore-line other
