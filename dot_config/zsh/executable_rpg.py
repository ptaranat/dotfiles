#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "d20",
# ]
# ///

import sys
import subprocess
from d20 import roll

def dice(expression):
    """Roll dice using d20 library and output through glow"""
    if not expression:
        print("Missing statement")
        return
    
    result = roll(expression)
    try:
        # Pipe through glow for formatting
        process = subprocess.Popen(['glow', '-'], stdin=subprocess.PIPE, text=True)
        process.communicate(str(result))
    except FileNotFoundError:
        # Fallback if glow is not available
        print(result)

def thaco(thac0, modifier=0):
    """Calculate THAC0 attack roll"""
    if not thac0:
        print("Missing THAC0")
        return
    
    expression = f"{thac0} [THAC0] - (d20 + {modifier})"
    result = str(roll(expression)) + "AC"
    
    try:
        # Pipe through glow for formatting
        process = subprocess.Popen(['glow', '-'], stdin=subprocess.PIPE, text=True)
        process.communicate(result)
    except FileNotFoundError:
        # Fallback if glow is not available
        print(result)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print("  rpg.py dice <expression>    # Roll dice (e.g., '2d6+3')")
        print("  rpg.py thaco <thac0> [mod]  # Calculate THAC0 attack")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "dice":
        if len(sys.argv) >= 3:
            dice(sys.argv[2])
        else:
            dice("")
    elif command == "thaco":
        if len(sys.argv) >= 3:
            modifier = int(sys.argv[3]) if len(sys.argv) >= 4 else 0
            thaco(sys.argv[2], modifier)
        else:
            thaco("")
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)