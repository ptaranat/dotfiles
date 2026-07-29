# Powerlevel10k, split so it can be upgraded without losing local changes.
# p10k.zsh is stock p10k-rainbow, vendored verbatim: never edit it, re-copy
# from znap/romkatv/powerlevel10k/config/p10k-rainbow.zsh to update.
# overrides.zsh holds every customisation and must load second, since later
# files win. The instant-prompt block lives at the top of .zshrc by necessity.

local _prompt_dir=${ZDOTDIR:-$HOME/.config/zsh}/prompt

for _f in p10k overrides; do
	[[ -r $_prompt_dir/$_f.zsh ]] && source $_prompt_dir/$_f.zsh
done
unset _f _prompt_dir
