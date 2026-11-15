#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
cat > "$TMP/tiny.txt" <<'DATA'
<h1>Apple</h1> Apple banana. Banana apple!
The apple is red? A banana is yellow.
DATA
expect() {
  local label=$1 result=$2 pattern=$3
  if grep -Eq -- "$pattern" <<< "$result"; then echo "PASS: $label"; else echo "FAIL: $label"; printf '%s\n' "$result"; exit 1; fi
}
clean=$(./main.sh clean "$TMP/tiny.txt")
if grep -qE '<|[.!?]' <<< "$clean"; then echo 'FAIL: tag/punctuation cleanup'; exit 1; else echo 'PASS: sed cleanup'; fi
search=$(./main.sh search "$TMP/tiny.txt" 'banana')
expect 'regex search with line numbers' "$search" '^1:.*banana'
expect 'grep second matching line' "$search" '^2:.*banana'
no_match=$(./main.sh search "$TMP/tiny.txt" 'zebra')
expect 'no match handling' "$no_match" '^No matches found\.$'
frequency=$(./main.sh frequency "$TMP/tiny.txt" 3)
expect 'frequency apple' "$frequency" $'^apple\t4$'
expect 'frequency banana' "$frequency" $'^banana\t3$'
if grep -Eq '^the[[:space:]]' <<< "$frequency"; then echo 'FAIL: stopwords'; exit 1; else echo 'PASS: stopword filtering'; fi
keep=$(./main.sh frequency "$TMP/tiny.txt" 20 --keep-stopwords)
expect 'option to keep stopwords' "$keep" $'^the\t1$'
sentences=$(./main.sh sentences "$TMP/tiny.txt")
expect 'sentence count' "$sentences" '^Sentences: 4$'
report=$(./main.sh report "$TMP/tiny.txt" 3)
expect 'saved report' "$report" '^Report saved to: '
if ./main.sh frequency "$TMP/tiny.txt" 0 >/dev/null 2>&1; then echo 'FAIL: invalid N accepted'; exit 1; else echo 'PASS: invalid N rejected'; fi
printf 'ALL TESTS PASSED\n'
