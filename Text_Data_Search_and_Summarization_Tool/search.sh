#!/usr/bin/env bash
# Search with grep extended regular expressions and report line numbers.
set -euo pipefail
if [[ $# -ne 2 || ! -f "$1" ]]; then
  echo "Usage: $0 <input-file> <extended-regex-pattern>" >&2; exit 2
fi
file=$1
pattern=$2
if grep -Ein -- "$pattern" "$file"; then
  :
else
  status=$?
  if [[ $status -eq 1 ]]; then
    echo "No matches found."
  else
    exit "$status"
  fi
fi
