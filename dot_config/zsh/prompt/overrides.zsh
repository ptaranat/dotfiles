typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
	dir
	vcs
)

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

typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

# quiet: otherwise the rc.d/00-banner.zsh output triggers a warning.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Empty, not unset: unset falls back to a folder icon.
typeset -g POWERLEVEL9K_DIR_CLASSES=()

typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=

# Unset first: the template declares it as an array.
unset POWERLEVEL9K_BATTERY_STAGES
typeset -g POWERLEVEL9K_BATTERY_STAGES=$'\uf58d\uf579\uf57a\uf57b\uf57c\uf57d\uf57e\uf57f\uf580\uf581\uf578'

typeset -g POWERLEVEL9K_TERRAFORM_VERSION_SHOW_ON_COMMAND='terraform|tf|tofu'

# Only change from stock: ahead/behind counts always shown.
function my_git_formatter() {
	emulate -L zsh

	if [[ -n $P9K_CONTENT ]]; then
		typeset -g my_git_format=$P9K_CONTENT
		return
	fi

	if (( $1 )); then
		local       meta='%f'     # default foreground
		local      clean='%0F'    # black foreground
		local   modified='%0F'    # black foreground
		local  untracked='%0F'    # black foreground
		local conflicted='%1F'    # red foreground
	else
		local       meta='%f'     # default foreground
		local      clean='%0F'    # black foreground
		local   modified='%0F'    # black foreground
		local  untracked='%0F'    # black foreground
		local conflicted='%0F'    # black foreground
	fi

	local res

	if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
		local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
		(( $#branch > 32 )) && branch[13,-13]="…"
		res+="${clean}${branch//\%/%%}"
	fi

	if [[ -n $VCS_STATUS_TAG
			&& -z $VCS_STATUS_LOCAL_BRANCH ]]; then
		local tag=${(V)VCS_STATUS_TAG}
		(( $#tag > 32 )) && tag[13,-13]="…"
		res+="${meta}#${clean}${tag//\%/%%}"
	fi

	[[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&
		res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"

	if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
		res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
	fi

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
