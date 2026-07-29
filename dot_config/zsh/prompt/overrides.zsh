# Local powerlevel10k customisations. p10k.zsh is the stock template, vendored
# verbatim; everything personal lives here and is sourced after it, so it wins.

# --- prompt shape ------------------------------------------------------------

# Single line: no `newline` element either side, no blank line between prompts.
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
	dir
	vcs
)

# p10k's version-manager segments (asdf, pyenv, nvm, rbenv) are all absent since
# mise replaced those tools. `mise current` answers the same question on demand.
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
	status
	command_execution_time
	background_jobs
	direnv
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

# Collapse previous prompts to the prompt character, keeping scrollback readable.
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

# quiet, not verbose: 00-banner.zsh prints on every start, which verbose would
# report as unexpected console output every time.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# --- appearance --------------------------------------------------------------

# Empty rather than unset: with no classes p10k falls back to styling that
# includes a folder icon.
typeset -g POWERLEVEL9K_DIR_CLASSES=()

# Drop the icons from these segments; the content is self-explanatory.
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=

# Nerd Font battery glyphs. The template declares this as an array and zsh
# refuses the retype to a scalar, so drop the array first.
unset POWERLEVEL9K_BATTERY_STAGES
typeset -g POWERLEVEL9K_BATTERY_STAGES=$'\uf58d\uf579\uf57a\uf57b\uf57c\uf57d\uf57e\uf57f\uf580\uf581\uf578'

# Only while running terraform, not in every directory holding .tf files.
typeset -g POWERLEVEL9K_TERRAFORM_VERSION_SHOW_ON_COMMAND='terraform|tf|tofu'

# --- git formatter -----------------------------------------------------------

# Redefined rather than patched into the vendored file. Only change from stock:
# ahead/behind counts show unconditionally, instead of falling back to printing
# the remote branch name.
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

	# Counts: ⇣behind ⇡ahead (remote), ⇠behind ⇢ahead (push remote), *stashes,
	# ~conflicts, +staged, !unstaged, ?untracked, plus the action for an
	# in-progress merge or rebase.
	(( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
	(( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
	(( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"

	(( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
	(( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
	(( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
	(( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
	[[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
	(( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
	(( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
	(( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
	(( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}?${VCS_STATUS_NUM_UNTRACKED}"

	typeset -g my_git_format=$res
}
