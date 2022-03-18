set fish_greeting
set -gx GPG_TTY (tty)
set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'

set fzf_fd_opts --hidden --exclude=.git
set fzf_preview_dir_cmd exa --all --color=always

zoxide init --cmd j fish | source
