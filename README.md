# dotfiles

macOS config, managed with [chezmoi](https://chezmoi.io).

## Bootstrap a new machine

```sh
xcode-select --install
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply ptaranat
```

The first line is a GUI prompt and has to finish before the second: it provides
`git`, and the compiler Homebrew needs. Nothing here can automate it.

`init` asks three questions and keeps the answers in
`~/.config/chezmoi/chezmoi.toml`, never in this public repo: whether this is a
work machine, the commit email, and the path to the SSH signing public key.
The first apply then installs Homebrew if it is missing (it asks for your
password), writes every file, and installs the Brewfile.

`-b "$HOME/.local/bin"` matters: without it chezmoi installs to `./bin` in the
current directory, which is not on `$PATH` for later runs.

Tailscale is deliberately not in the Brewfile. The app is installed once per
machine, however that machine allows: the App Store here, possibly MDM on a
work machine. A cask entry would collide with an App Store copy and fail the
package script on every apply. The app ships its own CLI (Settings > Install
CLI), which stays in step with the daemon; the Homebrew formula did not.

Then, once the keys are on the machine (the signing key, and an SSH key GitHub
accepts):

```sh
chezmoi apply    # turns commit signing on; on a work machine, clones the work repo
mise install     # runtimes declared in ~/.config/mise/config.toml
~/.tmux/plugins/tpm/bin/install_plugins
```

Both halves are safe to run before the keys exist. Signing stays off until the
key file is present, so commits work (unsigned) in the meantime. The private
work repo is only declared on a work machine that has the key, because a
failed clone aborts the entire apply.

To change an answer later: `chezmoi init --prompt`.

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
dot_config/{ghostty,alacritty,atuin,mise,aerospace,fzf,git,nvim}/
dot_gitconfig.tmpl, dot_gitignore_global, dot_tmux.conf, private_dot_gnupg/
Brewfile                every formula, cask and tap for the mac
.chezmoidata.yaml       apt package lists for the Linux box
run_*                   install Homebrew, packages, macOS defaults, completions
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
| `init.zsh` | sources the two in order, later files winning |

To take a p10k update, overwrite the vendored file and re-test:

```sh
cp ~/.local/share/znap/romkatv/powerlevel10k/config/p10k-rainbow.zsh \
   "$(chezmoi source-path)/dot_config/zsh/prompt/p10k.zsh"
```

## Externals

`.chezmoiexternal.toml.tmpl` clones repos that are not vendored here:

- `~/.local/share/znap/zsh-snap`: the zsh plugin manager. `.zshrc` sources it,
  so without it there are no plugins and no prompt.
- `~/.tmux/plugins/tpm`: the tmux plugin manager.
- `~/.config/ghostty/shaders`: cursor shaders, mac only.
- `~/.config/zsh/work`: private work config, sourced after `rc.d` so it can
  override. Only on a machine initialised as a work machine, and only once its
  signing key is present, since chezmoi aborts the whole apply when a clone
  fails.

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
