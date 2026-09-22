# Git workflow helpers, adapted from 2KAbhishek/dots2k.

# From the remote's own HEAD, not a hardcoded "main", so master/develop work.
_git_base_branch() {
	local base
	base=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null)
	if [[ -n $base ]]; then
		print -r -- "origin/${base##*/}"
		return
	fi
	# origin/HEAD is often unset on a fresh clone, so ask the remote first.
	base=$(git ls-remote --symref origin HEAD 2>/dev/null | awk '/^ref:/ {print $2; exit}')
	if [[ -n $base ]]; then
		print -r -- "origin/${base##*/}"
		return
	fi
	for base in origin/main origin/master origin/develop main master; do
		git rev-parse --verify --quiet "$base" >/dev/null && { print -r -- "$base"; return }
	done
	print -r -- HEAD
}

# Browse everything this branch changed, with the diff in the preview pane.
# Enter opens the file in $EDITOR.
review() {
	git rev-parse --git-dir >/dev/null 2>&1 || { print -u2 "not a git repo"; return 1 }
	local base=$(_git_base_branch)
	git diff --name-only "$base"...HEAD | fzf \
		--preview "git diff --color=always $base...HEAD -- {} | delta --width=\$FZF_PREVIEW_COLUMNS" \
		--preview-window 'right:60%:wrap' \
		--bind "enter:execute(${EDITOR:-vim} {})" \
		--header "changed vs $base -- enter to edit, esc to quit"
}

# Run a command over only the changed files. $1 picks the set: "diff" is the
# branch versus its base, "modified" is the dirty worktree.
_git_run_on_files() {
	local mode=$1 pattern=$2
	shift 2
	git rev-parse --git-dir >/dev/null 2>&1 || { print -u2 "not a git repo"; return 1 }

	local -a files
	case $mode in
		diff)     files=(${(f)"$(git diff --name-only --diff-filter=d $(_git_base_branch)...HEAD 2>/dev/null)"}) ;;
		modified) files=(${(f)"$(git diff --name-only --diff-filter=d HEAD 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)"}) ;;
		*)        print -u2 "usage: _git_run_on_files <diff|modified> <pattern> <cmd...>"; return 1 ;;
	esac

	files=(${(M)files:#*${~pattern}*})
	# A rename leaves the old path in the list, so skip what is gone.
	files=(${(@)files:#""})
	local -a existing
	local f
	for f in $files; do [[ -f $f ]] && existing+=$f; done

	if (( ! $#existing )); then
		print "no matching changed files"
		return 0
	fi
	print -r -- "-> $* ${#existing} file(s)"
	"$@" $existing
}

# Lint or test only what changed. `-d` variants use the branch diff; the plain
# ones use the dirty worktree.
lintjs()  { _git_run_on_files modified '.(js|jsx|ts|tsx|mjs|cjs)' npx eslint --fix "$@" }
lintjsd() { _git_run_on_files diff     '.(js|jsx|ts|tsx|mjs|cjs)' npx eslint --fix "$@" }
fmtjs()   { _git_run_on_files modified '.(js|jsx|ts|tsx|json|md|css|scss|html|yml|yaml)' npx prettier --write "$@" }
lintpy()  { _git_run_on_files modified '.py' ruff check --fix "$@" }
fmtpy()   { _git_run_on_files modified '.py' ruff format "$@" }
lintsh()  { _git_run_on_files modified '.sh' shellcheck "$@" }
lintgo()  { _git_run_on_files modified '.go' gofmt -l -w "$@" }

# rg -> fzf -> open the match in $EDITOR at the right line.
search() {
	[[ -n $1 ]] || { print -u2 "usage: search <pattern>"; return 1 }
	local result
	result=$(rg --line-number --no-heading --color=always --smart-case "$1" 2>/dev/null |
		fzf --ansi --delimiter=: \
			--preview 'bat --style=numbers --color=always --highlight-line={2} --line-range=$(( {2} > 10 ? {2} - 10 : 1 )): {1}' \
			--preview-window 'right:60%:wrap') || return
	[[ -n $result ]] || return
	local file=${result%%:*} line=${${result#*:}%%:*}
	${EDITOR:-vim} "+${line}" "$file"
}

# Re-run the last command under sudo.
plz() { eval "sudo $(fc -ln -1)" }

# Run a command in another directory without leaving this one.
xin() {
	local dir=$1
	shift
	(cd "$dir" && "$@")
}

# Compare a tool's apt candidate against its brew formula and print the swap.
# Prints rather than runs: an auto-applying version is how `brew reinstall
# node` cascaded through llhttp and broke eza and bat.
#
# Read it as "is the newer version worth it", not "newer wins". Debian freezes
# at release and brew tracks upstream, so brew drifts ahead of everything over
# time; taking every gap rebuilds the 22GB prefix.
_pkgv_norm() { print -r -- "${${1#*:}%%[-~]*}" }

pkgv() {
	if (( ! $# )); then
		print -u2 "usage: pkgv <tool> [apt-name] [brew-formula]"
		return 1
	fi

	# Where apt package, brew formula and binary are not the same word. A wrong
	# guess reports "not available", which reads as missing rather than mislooked.
	local -A _apt=(rg ripgrep fd fd-find tldr tealdeer)
	local -A _brew=(rg ripgrep fd-find fd tldr tealdeer)
	local -A _bin=(ripgrep rg fd-find fd tealdeer tldr)

	local tool=$1
	local apt_name=${2:-${_apt[$tool]:-$tool}}
	local formula=${3:-${_brew[$tool]:-$tool}}
	local binary=${_bin[$tool]:-$tool}
	local apt_raw brew_raw apt_v brew_v winner

	if (( $+commands[apt-cache] )); then
		apt_raw=$(apt-cache policy "$apt_name" 2>/dev/null | awk '/Candidate:/{print $2}')
		[[ $apt_raw == "(none)" ]] && apt_raw=
	fi
	if (( $+commands[brew] )); then
		brew_raw=$(brew info --json=v2 "$formula" 2>/dev/null |
			jq -r '.formulae[0].versions.stable // empty' 2>/dev/null)
	fi

	apt_v=$(_pkgv_norm "$apt_raw")
	brew_v=$(_pkgv_norm "$brew_raw")
	printf '%-8s apt %-12s brew %-12s' "$tool" "${apt_v:--}" "${brew_v:--}"

	if [[ -z $apt_v && -z $brew_v ]]; then
		print -- " (neither)"; return 1
	elif [[ -z $brew_v ]]; then
		print -- " -> apt only"; return 0
	elif [[ -z $apt_v ]]; then
		print -- " -> brew only"; return 0
	elif [[ $apt_v == "$brew_v" ]]; then
		print -- " -> tie, prefer apt"
	elif [[ $(printf '%s\n%s\n' "$apt_v" "$brew_v" | sort -V | tail -1) == "$brew_v" ]]; then
		print -- " -> BREW newer"; winner=brew
	else
		print -- " -> APT newer"; winner=apt
	fi

	local current=${commands[$binary]}
	case $winner in
	brew) print -- "    brew install $formula"
		[[ $current == /usr/* ]] && print -- "    # apt copy stays as the floor; brew shadows it on PATH" ;;
	apt)  print -- "    sudo apt-get install -y --no-upgrade $apt_name"
		[[ $current == *linuxbrew* ]] && print -- "    brew uninstall $formula   # check \`brew uses --installed $formula\` first" ;;
	esac
	[[ -n $current ]] && print -- "    now: $current"
	return 0
}

# Browse the installed figlet/toilet fonts with a live preview. `fonts` uses a
# placeholder word, `fonts NETDECKER` your own text; enter renders it full size.
fonts() {
	local dir=${FIGLET_FONTDIR:-/usr/share/figlet}
	local text=${*:-Spellbook}
	local font

	font=$(print -rl -- $dir/*.(flf|tlf)(:t:r) | sort -f |
		fzf --prompt='font> ' --height=90% --layout=reverse --border \
			--preview-window='right:70%:wrap' \
			--preview="toilet -t -d ${(q)dir} -f {} ${(q)text} 2>&1 | head -24") || return
	[[ -n $font ]] || return

	toilet -t -d $dir -f "$font" "$text"
	print -r -- "# toilet -t -f ${(q)font} ${(q)text}"
}
