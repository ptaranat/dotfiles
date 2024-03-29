# source /Users/panat/projects/rpg/roll/bash_completion/roll
znap install matteocorti/roll
source ~[roll]/bash_completion/roll

# outputs avrae/d20 to glow
function dice() {
  if [ -n "$1" ]; then
    local cmd
    cmd="from d20 import roll; print(roll('$1'))"
    python3 -c $cmd | glow -
  else
    echo "Missing statement"
  fi
}

function thaco() {
  if [ -n "$1" ]; then
    cmd="from d20 import roll; print(str(roll('$1 [THAC0] - (d20 + ${2:-0})')) + 'AC')"
    python3 -c $cmd | glow -
  else
    echo "Missing THAC0"
  fi
}
