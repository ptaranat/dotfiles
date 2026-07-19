# Powerlevel10k prompt, assembled from three files.
#
# The split exists so p10k can be upgraded without losing local changes. The
# generated config is ~1800 lines; hand-editing it means every regeneration
# produces an unreadable diff and personal settings get clobbered silently.
#
#   p10k.zsh       stock p10k-rainbow, vendored verbatim -- never edit this.
#                  To take an upstream update, copy the new template over it:
#                    cp ~/.local/share/znap/romkatv/powerlevel10k/config/p10k-rainbow.zsh \
#                       $ZDOTDIR/prompt/p10k.zsh
#   overrides.zsh  every local customisation
#
# Order matters: later files win, so overrides must follow p10k.zsh.
# The instant-prompt block itself lives at the top of .zshrc, where it has to
# be, rather than here.

local _prompt_dir=${ZDOTDIR:-$HOME/.config/zsh}/prompt

for _f in p10k overrides; do
	[[ -r $_prompt_dir/$_f.zsh ]] && source $_prompt_dir/$_f.zsh
done
unset _f _prompt_dir
