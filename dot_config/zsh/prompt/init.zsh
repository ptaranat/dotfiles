# p10k prompt, split so it can be upgraded without losing local changes: the
# generated config is ~1800 lines and hand-editing it clobbers them silently.
#
#   p10k.zsh       stock p10k-rainbow, vendored verbatim. Never edit; to update,
#                  copy config/p10k-rainbow.zsh from the znap checkout over it.
#   overrides.zsh  every local customisation
#
# Later files win, so overrides must follow p10k.zsh. The instant-prompt block
# lives at the top of .zshrc, where it has to be.

local _prompt_dir=${ZDOTDIR:-$HOME/.config/zsh}/prompt

for _f in p10k overrides; do
	[[ -r $_prompt_dir/$_f.zsh ]] && source $_prompt_dir/$_f.zsh
done
unset _f _prompt_dir
