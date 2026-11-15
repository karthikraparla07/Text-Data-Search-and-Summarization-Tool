#!/usr/bin/env bash
# Clean plain text or simple HTML using sed.
set -euo pipefail
if [[ $# -lt 1 || $# -gt 2 || ! -f "$1" ]]; then
  echo "Usage: $0 <input-file> [--keep-punctuation]" >&2
  exit 2
fi
if [[ $# -eq 2 && "$2" != "--keep-punctuation" ]]; then
  echo "Unknown option: $2" >&2; exit 2
fi
# Convert tags into spaces so neighboring words don't join. Handle common entities.
if [[ ${2:-} == "--keep-punctuation" ]]; then
  sed -E 's/<[^>]*>/ /g; s/&nbsp;/ /g; s/&amp;/ \& /g; s/&lt;/ /g; s/&gt;/ /g; s/&quot;/ /g; s/&#39;/ /g; s/\r//g' "$1"
else
  sed -E 's/<[^>]*>/ /g; s/&nbsp;/ /g; s/&amp;/ \& /g; s/&lt;/ /g; s/&gt;/ /g; s/&quot;/ /g; s/&#39;/ /g; s/\r//g; s/[^[:alnum:][:space:]]+/ /g; s/[[:space:]]+/ /g' "$1"
fi
