# Small diagnostics for things that are awkward to inspect from outside the
# shell. These must be functions, not scripts: the state they report on lives
# in shell variables, which a separate process cannot see.

# Explain what the mise prompt segment is doing and why.
mise-prompt-debug() {
	local d tool ver
	print "cwd:         $PWD"
	print "global map:  ${(kv)_p9k_mise_global:-<empty>}"
	print "hide_global: ${POWERLEVEL9K_MISE_HIDE_GLOBAL:-<unset>}"
	print "max segments: ${POWERLEVEL9K_MISE_MAX_SEGMENTS:-<unset>}"
	print "mise PATH entries:"
	for d in $path; do
		[[ $d == *mise/installs/* ]] || continue
		print "  raw:      $d"
		print "  resolved: ${d:A}"
		if [[ ${d:A} =~ "mise/installs/([^/]+)/([^/]+)(/bin)?$" ]]; then
			tool=${(L)match[1]}; ver=$match[2]
			print -n "  -> tool=$tool version=$ver global=${_p9k_mise_global[$tool]:-<none>} => "
			if [[ $POWERLEVEL9K_MISE_HIDE_GLOBAL == true && ${_p9k_mise_global[$tool]} == $ver ]]; then
				print "HIDDEN (matches global)"
			else
				print "SHOWN"
			fi
		fi
	done
	print "segment renders as:"
	(
		# shadow p10k so the segment's output can be captured rather than drawn
		p10k() {
			local s t
			shift
			while (( $# )); do
				case $1 in
					-s) s=$2; shift 2 ;;
					-t) t=$2; shift 2 ;;
					*) shift ;;
				esac
			done
			print -n "  [$s $t]"
		}
		prompt_mise
		print ""
	)
}
