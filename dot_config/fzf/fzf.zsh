# fzf shell integration. The plugin (unixorn/fzf-zsh-plugin) has no XDG support,
# so .zshrc points FZF_PATH here. `fzf --zsh` emits bindings from the installed
# binary so nothing goes stale on upgrade. zsh-vi-mode steals ctrl-R/ctrl-T, so
# .zshrc re-sources this via zvm_after_init_commands.
source <(fzf --zsh)
