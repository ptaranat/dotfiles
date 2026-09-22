# p10k.zsh is vendored verbatim; put local changes in overrides.zsh.

local _prompt_dir=${ZDOTDIR:-$HOME/.config/zsh}/prompt

for _f in p10k overrides; do
	[[ -r $_prompt_dir/$_f.zsh ]] && source $_prompt_dir/$_f.zsh
done
unset _f _prompt_dir
