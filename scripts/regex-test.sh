#!/bin/bash

# Check commandline arguments
[ "$#" -eq 2 ] || { echo "Usage: $0 <( command ) command.rgx" >&2; exit 1; }

# Check pattern file
[ -f "$2" ] || { echo "Regex file does not exist: $2" >&2; exit 1; }

# Compare output with pattern (until we reach end of pattern)
IFS=''
while read -r output ; read -r pattern <&3 || [[ -n "$pattern" ]] ; do
  [[ "$output" =~ ^[[:space:]]*${pattern}[[:space:]]*$ ]] || { echo "Regex does not match!"; exit 1; }
done < "$1" 3< "$2"

# Check if we reached end of output, too
[[ -n "$output" ]] && { echo "Regex does not match!"; exit 1; }

echo "Regex does match!"
exit 0
