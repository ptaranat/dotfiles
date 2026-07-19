# Git workflow helpers, adapted from 2KAbhishek/dots2k.

# The branch this one diverged from, from the remote's own HEAD rather than a
# hardcoded "main". Repos that still use master, or use develop, work unchanged.
_git_base_branch() {
	local base
	base=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null)
	if [[ -n $base ]]; then
		print -r -- "origin/${base##*/}"
		return
	fi
	# origin/HEAD is often unset on a fresh clone; ask the remote directly, then
	# fall back to whichever conventional name exists.
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

# Run a command over only the files that changed, rather than the whole repo.
#
# $1 selects which set: "diff" is everything on this branch versus its base,
# "modified" is the dirty worktree. The distinction matters -- linting a whole
# monorepo is slow, and the two questions ("what did I write" vs "what have I
# not committed") have different answers.
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
	# Only pass files that still exist; a rename leaves the old path in the list.
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
