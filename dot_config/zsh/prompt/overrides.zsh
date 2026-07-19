# Local powerlevel10k customisations.
#
# prompt/p10k.zsh is the stock p10k-rainbow template, vendored verbatim and
# never hand-edited, so it can be replaced wholesale when p10k updates and the
# diff stays reviewable. Everything personal lives here instead.
#
# Sourced after it, so these assignments win.

# --- prompt shape ------------------------------------------------------------

# Single line: no `newline` element on either side, and no blank line between
# prompts.
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
	dir
	vcs
)

# The version-manager segments p10k ships (asdf, pyenv, nodenv, nvm, rbenv,
# rvm, goenv, jenv, plenv, phpenv, luaenv, scalaenv, fvm, haskell_stack,
# nodeenv) are all superseded by the single `mise` segment defined in
# prompt/mise.zsh, so none of them appear here.
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
	status
	command_execution_time
	background_jobs
	direnv
	mise
	virtualenv
	anaconda
	perlbrew
	kubecontext
	terraform
	aws
	aws_eb_env
	azure
	gcloud
	google_app_cred
	toolbox
	context
	nordvpn
	ranger
	yazi
	nnn
	lf
	xplr
	vim_shell
	midnight_commander
	nix_shell
	vi_mode
	chezmoi_shell
	todo
	timewarrior
	taskwarrior
	per_directory_history
)

# --- behaviour ---------------------------------------------------------------

# Collapse previous prompts to just the prompt character, keeping scrollback
# readable when reading back through a long session.
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

# quiet, not verbose: rc.d/00-banner.zsh prints a banner on every start, and
# verbose would report that as unexpected console output every single time.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# --- appearance --------------------------------------------------------------

# Empty rather than unset. With no classes defined p10k falls back to its
# default directory styling, which includes a folder icon; an empty array
# suppresses that and leaves a plain path.
typeset -g POWERLEVEL9K_DIR_CLASSES=()

# Drop the icons from these segments; the content is self-explanatory.
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=

# Nerd Font battery glyphs in place of the stock block characters. The vendored
# template declares this as an array; a scalar string of glyphs is equivalent to
# p10k but zsh refuses the retype, so drop the array first.
unset POWERLEVEL9K_BATTERY_STAGES
typeset -g POWERLEVEL9K_BATTERY_STAGES=$'\uf58d\uf579\uf57a\uf57b\uf57c\uf57d\uf57e\uf57f\uf580\uf581\uf578'

# Only show the terraform version while actually running terraform, rather than
# in every directory containing .tf files.
typeset -g POWERLEVEL9K_TERRAFORM_VERSION_SHOW_ON_COMMAND='terraform|tf|tofu'

# --- git formatter -----------------------------------------------------------

# Redefined rather than patched into the vendored file. The only change from
# stock is that ahead/behind counts are shown unconditionally: stock wraps them
# in `if (( AHEAD || BEHIND ))` with an `elif [[ -n $VCS_STATUS_REMOTE_BRANCH ]]`
# branch that can print the remote branch name instead, which is noise here.
function my_git_formatter() {
	emulate -L zsh

	if [[ -n $P9K_CONTENT ]]; then
		# If P9K_CONTENT is not empty, use it. It's either "loading" or from
		# gitstatus_query in the vcs segment.
		typeset -g my_git_format=$P9K_CONTENT
		return
	fi

	if (( $1 )); then
		# Styling for up-to-date Git status.
		local       meta='%f'     # default foreground
		local      clean='%0F'    # black foreground
		local   modified='%0F'    # black foreground
		local  untracked='%0F'    # black foreground
		local conflicted='%1F'    # red foreground
	else
		# Styling for incomplete and stale Git status.
		local       meta='%f'     # default foreground
		local      clean='%0F'    # black foreground
		local   modified='%0F'    # black foreground
		local  untracked='%0F'    # black foreground
		local conflicted='%0F'    # black foreground
	fi

	local res

	if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
		local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
		# If local branch name is at most 32 characters long, show it in full.
		(( $#branch > 32 )) && branch[13,-13]="…"
		res+="${clean}${branch//\%/%%}"
	fi

	if [[ -n $VCS_STATUS_TAG
			# Show tag only if not on a branch.
			&& -z $VCS_STATUS_LOCAL_BRANCH ]]; then
		local tag=${(V)VCS_STATUS_TAG}
		(( $#tag > 32 )) && tag[13,-13]="…"
		res+="${meta}#${clean}${tag//\%/%%}"
	fi

	# Display the current Git commit if there is no branch and no tag.
	[[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&
		res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"

	# Show tracking branch name if it differs from local branch.
	if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
		res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
	fi

	# Display ahead/behind counts whenever they are non-zero.
	# ⇣42 if behind the remote.
	(( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
	# ⇡42 if ahead of the remote; no leading space if also behind.
	(( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
	(( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"

	# ⇠42 if behind the push remote.
	(( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
	(( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
	# ⇢42 if ahead of the push remote.
	(( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
	# *42 if have stashes.
	(( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
	# 'merge' if the repo is in an unusual state.
	[[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
	# ~42 if have merge conflicts.
	(( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
	# +42 if have staged changes.
	(( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
	# !42 if have unstaged changes.
	(( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
	# ?42 if have untracked files.
	(( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}?${VCS_STATUS_NUM_UNTRACKED}"

	typeset -g my_git_format=$res
}
