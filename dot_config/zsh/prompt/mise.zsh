# mise runtime versions, as a powerlevel10k prompt segment.
# p10k has no built-in one: it predates mise and only ships asdf.
# https://github.com/romkatv/powerlevel10k/issues/2212
#
# Sourced after prompt/p10k.zsh so these definitions win.

###########################[ mise: runtime versions ]###########################
# p10k has no built-in mise segment; it predates mise and only ships asdf.
# https://github.com/romkatv/powerlevel10k/issues/2212
#
# Versions are read out of $path rather than by calling mise. mise activation
# prepends .../mise/installs/<tool>/<version>/bin, so the active versions are
# already sitting in the environment -- no subprocess on any prompt, and it
# reflects what mise actually resolved rather than what some config file asks
# for. An earlier version parsed .mise.toml/.tool-versions/.nvmrc directly and
# was both more code and less accurate.
#
# Approach adapted from 2KAbhishek/dots2k.

# Global versions, so the prompt can hide anything matching the machine default
# and show only what a project overrides.
#
# Cached to disk rather than shelling out to `mise ls` on every shell start,
# which measured ~18ms. The cache is rebuilt whenever the mise config is newer
# than it, which also fixes a real bug: installing a new global tool mid-session
# used to leave it absent from this map, so it looked like a project override
# and showed in the prompt everywhere until the shell was restarted.
typeset -gA _p9k_mise_global
if (( $+commands[mise] )); then
  () {
    local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/mise-global"
    local cfg="${MISE_GLOBAL_CONFIG_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml}"
    if [[ ! -s $cache || $cfg -nt $cache ]]; then
      [[ -d ${cache:h} ]] || mkdir -p ${cache:h}
      mise ls --offline 2>/dev/null |
        awk '$3 ~ /config\.toml$|\.tool-versions$|\.mise\.toml$/ {print $1, $2}' >| $cache
    fi
    local tool version
    while read -r tool version; do
      [[ -n $tool ]] && _p9k_mise_global[$tool]=$version
    done < $cache
  }
fi

typeset -g POWERLEVEL9K_MISE_MAX_SEGMENTS=2
typeset -g POWERLEVEL9K_MISE_HIDE_GLOBAL=true

# Literal Nerd Font glyphs, written as \u escapes so this file stays ASCII
# and the codepoints cannot be mangled in transit.
#
# These cannot be p10k icon *names*: unlike the built-in segments, which pass
# a name to _p9k_prompt_segment for lookup, `p10k segment -i` emits its
# argument verbatim, so -i NODE_ICON renders the literal text "NODE_ICON".
# Tools absent here fall back to their name rather than rendering as tofu.
typeset -gA _p9k_mise_icons=(
  node      $'\ue718'  python    $'\ue73c'
  go        $'\ue627'  rust      $'\ue7a8'
  ruby      $'\ue739'  java      $'\ue738'
  php       $'\ue73d'  lua       $'\ue620'
  elixir    $'\ue62d'  swift     $'\ue755'
  deno      $'\ue628'  npm       $'\ue71e'
  pnpm      $'\ue71e'  yarn      $'\ue6a7'
  bun       $'\U000f06a6'
  terraform $'\U000f1062'
)

# Colours are palette indices 0-7, not 256-colour values. Indices are what
# the terminal theme defines, so these follow srcery; a fixed 256-colour like
# 34 or 208 ignores the theme and reads as foreign next to the other segments.
typeset -g POWERLEVEL9K_MISE_FOREGROUND=0
typeset -g POWERLEVEL9K_MISE_BACKGROUND=6
typeset -g POWERLEVEL9K_MISE_NODE_BACKGROUND=2
typeset -g POWERLEVEL9K_MISE_PYTHON_BACKGROUND=4
typeset -g POWERLEVEL9K_MISE_GO_BACKGROUND=6
typeset -g POWERLEVEL9K_MISE_RUST_BACKGROUND=1
typeset -g POWERLEVEL9K_MISE_RUBY_BACKGROUND=1
typeset -g POWERLEVEL9K_MISE_JAVA_BACKGROUND=1
typeset -g POWERLEVEL9K_MISE_ERLANG_BACKGROUND=1
typeset -g POWERLEVEL9K_MISE_PHP_BACKGROUND=5
typeset -g POWERLEVEL9K_MISE_ELIXIR_BACKGROUND=5
typeset -g POWERLEVEL9K_MISE_LUA_BACKGROUND=4
typeset -g POWERLEVEL9K_MISE_NPM_BACKGROUND=3
typeset -g POWERLEVEL9K_MISE_PNPM_BACKGROUND=3
typeset -g POWERLEVEL9K_MISE_YARN_BACKGROUND=3
typeset -g POWERLEVEL9K_MISE_BUN_BACKGROUND=3
typeset -g POWERLEVEL9K_MISE_DENO_BACKGROUND=7

function prompt_mise() {
  local dir tool version lower
  local -A seen
  local -i count=0
  for dir in $path; do
    [[ $dir == *mise/installs/* ]] || continue
    [[ ${dir:A} =~ "mise/installs/([^/]+)/([^/]+)(/bin)?$" ]] || continue
    lower=${(L)match[1]}
    version=$match[2]
    # mise ships `usage` as an internal dependency; it is not a runtime.
    [[ $lower == usage ]] && continue
    [[ -n ${seen[$lower]} ]] && continue
    [[ $POWERLEVEL9K_MISE_HIDE_GLOBAL == true &&
       ${_p9k_mise_global[$lower]} == $version ]] && continue
    (( POWERLEVEL9K_MISE_MAX_SEGMENTS > 0 &&
       count >= POWERLEVEL9K_MISE_MAX_SEGMENTS )) && break
    p10k segment -s "${(U)lower}" \
      -i "${_p9k_mise_icons[$lower]:-$lower}" -t "${version#v}"
    seen[$lower]=1
    (( count++ ))
  done
}
