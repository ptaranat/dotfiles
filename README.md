# dotfiles

macOS config, managed with [chezmoi](https://chezmoi.io).

## Bootstrap a new machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply ptaranat
brew bundle --file="$(chezmoi source-path)/Brewfile"
```

The `-b "$HOME/.local/bin"` matters: without it chezmoi installs to `./bin` in
the current directory, which will not be on `$PATH` for later `chezmoi update`
runs.

Run the two in that order. The first lays down the configs and clones the
externals; the second installs the tools those configs expect. The shell will
complain about missing commands in between, which is expected.

## Layout

chezmoi encodes file attributes in the name rather than the path, so
`dot_config/zsh/dot_zshrc` in this repo becomes `~/.config/zsh/.zshrc`, and
`executable_` marks a file that should be `chmod +x` on disk.

```
dot_zshenv              the only file in $HOME; points ZDOTDIR at ~/.config/zsh
dot_config/zsh/
  dot_zshrc             plugins, prompt, keybindings
  rc.d/*.zsh            sourced in order; NN- prefixes with gaps for insertion
  prompt/               see below
dot_config/{ghostty,alacritty,atuin,mise,aerospace,fzf,git}/
dot_gitconfig, dot_tmux.conf, dot_vimrc, dot_vim/, dot_gnupg/
Brewfile                every formula, cask and vscode extension
```

Configs follow XDG: only `~/.zshenv` lives in `$HOME`, and it exists purely to
point zsh at `~/.config/zsh`. History goes to `~/.local/state/zsh/history`.

### Prompt

`dot_config/zsh/prompt/` is split so powerlevel10k can be upgraded without
losing local changes:

| file | role |
| --- | --- |
| `p10k.zsh` | stock `p10k-rainbow`, vendored verbatim. **Never edit.** |
| `overrides.zsh` | every local customisation |
| `mise.zsh` | mise segment; p10k has no built-in equivalent |
| `init.zsh` | sources the three in order, later files winning |

To take a p10k update, overwrite the vendored file and re-test:

```sh
cp ~/.local/share/znap/romkatv/powerlevel10k/config/p10k-rainbow.zsh \
   "$(chezmoi source-path)/dot_config/zsh/prompt/p10k.zsh"
```

## Externals

`.chezmoiexternal.toml` clones repos that are not vendored here, replacing what
were git submodules:

- `~/.config/zsh/work` — private work config, sourced by `.zshrc` after `rc.d`
  so it can override. A machine without access to that repo skips it silently.
- `~/.config/ghostty/shaders` — cursor shaders.
- `~/.local/share/znap/zsh-snap` — the zsh plugin manager. `.zshrc` sources it,
  so without this a fresh machine has no plugins and no prompt.

## Day to day

```sh
chezmoi edit ~/.zshrc     # edit the source, not the deployed copy
chezmoi apply             # write changes out
chezmoi diff              # what would change
chezmoi update            # pull and apply
chezmoi cd                # shell in the source directory
```

Editing a deployed file directly is the one thing to avoid: the next `apply`
overwrites it. `chezmoi add <file>` pulls an on-disk change back into the repo
if it happens anyway.

## Tooling

Runtime versions come from [mise](https://mise.jdx.dev) (replacing fnm and
pyenv); Python packaging stays with `uv`. Shell history is in
[atuin](https://atuin.sh) on `Ctrl-R`, with sync off by default. Plugins load
through [znap](https://github.com/marlonrichert/zsh-snap).
