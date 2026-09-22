zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:*' fzf-preview-window 'right:55%:wrap'

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null | head -50'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null | head -50'
zstyle ':fzf-tab:complete:j:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null | head -50'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null | head -50'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null | head -50'

for _cmd in bat cat nvim vim nano rm cp mv; do
	zstyle ":fzf-tab:complete:${_cmd}:*" fzf-preview \
		'if [[ -d $realpath ]]; then eza -1 --color=always --icons $realpath | head -50; else bat --style=numbers --color=always --line-range=:100 $realpath 2>/dev/null || head -100 $realpath; fi'
done
unset _cmd

zstyle ':fzf-tab:complete:git-(add|diff|restore|checkout|switch|stash):*' fzf-preview \
	'case "$group" in
	"modified file") git diff --color=always -- $word | delta 2>/dev/null || git diff --color=always -- $word ;;
	"recent commit object name") git show --color=always $word | delta 2>/dev/null || git show --color=always $word ;;
	"branch"|"local head"|"remote head") git log --oneline --graph --color=always -20 $word ;;
	*) git log --oneline --graph --color=always -20 $word 2>/dev/null || eza -1 --color=always $realpath ;;
	esac'

zstyle ':fzf-tab:complete:git-(log|show|rebase|revert|cherry-pick):*' fzf-preview \
	'git show --color=always $word 2>/dev/null | delta 2>/dev/null || git log --oneline --color=always -20 $word 2>/dev/null'

zstyle ':fzf-tab:complete:(-command-|export|unset|printenv):*' fzf-preview \
	'echo ${(P)word}'

zstyle ':fzf-tab:complete:kill:*' fzf-preview \
	'ps -p $word -o pid=,user=,%cpu=,%mem=,command= 2>/dev/null'

zstyle ':fzf-tab:complete:chezmoi:*' fzf-preview \
	'chezmoi diff $word 2>/dev/null | head -100'

zstyle ':fzf-tab:complete:mise:*' fzf-preview \
	'mise ls $word 2>/dev/null | head -30'

zstyle ':fzf-tab:complete:brew-(install|info|uninstall|reinstall):*' fzf-preview \
	'brew info $word 2>/dev/null | head -40'

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Needed by the $group-based git preview above.
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' ignore-line other
