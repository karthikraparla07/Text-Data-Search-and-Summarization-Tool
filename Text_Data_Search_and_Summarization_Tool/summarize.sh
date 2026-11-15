#!/usr/bin/env bash
# Word frequency and sentence statistics via awk.
set -euo pipefail
BASE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
usage() { echo "Usage: $0 frequency <file> [top-N] [--keep-stopwords] | sentences <file> | report <file> [top-N]" >&2; exit 2; }
[[ $# -ge 2 ]] || usage
command=$1; file=$2
[[ -f "$file" ]] || { echo "File not found: $file" >&2; exit 2; }
frequency() {
  local n=${1:-10} keep=${2:-false}
  [[ "$n" =~ ^[1-9][0-9]*$ ]] || { echo "top-N must be a positive integer" >&2; exit 2; }
  "$BASE_DIR/cleanup.sh" "$file" |
  awk -v keep="$keep" -v stopfile="$BASE_DIR/stopwords.txt" '
    BEGIN { while ((getline s < stopfile) > 0) { sub(/\r$/, "", s); if (s != "") stop[tolower(s)]=1 } close(stopfile) }
    { for(i=1;i<=NF;i++) { w=tolower($i); if (w ~ /[[:alpha:]]/ && (keep == "true" || !(w in stop))) count[w]++ } }
    END { for (w in count) printf "%s\t%d\n", w, count[w] }
  ' | LC_ALL=C sort -t $'\t' -k2,2nr -k1,1 | head -n "$n" || true
}
sentences() {
  "$BASE_DIR/cleanup.sh" "$file" --keep-punctuation |
    awk '
      BEGIN { RS="[.!?]+"; sentence_count=0; total=0; min=0; max=0 }
      { s=$0; gsub(/[^[:alnum:][:space:]]/," ",s); n=split(s,a,/[[:space:]]+/); words=0
        for(i=1;i<=n;i++) if(a[i] ~ /[[:alnum:]]/) words++
        if(words>0) {sentence_count++;total+=words;if(min==0||words<min)min=words;if(words>max)max=words}
      }
      END { printf "Sentences: %d\nTotal words in sentences: %d\nAverage sentence length: %.2f words\nShortest sentence: %d words\nLongest sentence: %d words\n",sentence_count,total,(sentence_count?total/sentence_count:0),min,max }
    '
}
case "$command" in
  frequency)
    n=10; keep=false
    for arg in "${@:3}"; do
      if [[ "$arg" == "--keep-stopwords" ]]; then keep=true
      elif [[ "$arg" =~ ^[1-9][0-9]*$ ]]; then n=$arg
      else usage; fi
    done
    echo -e "WORD\tCOUNT"
    frequency "$n" "$keep"
    ;;
  sentences) [[ $# -eq 2 ]] || usage; sentences ;;
  report)
    [[ $# -le 3 ]] || usage
    n=${3:-10}
    [[ "$n" =~ ^[1-9][0-9]*$ ]] || usage
    echo "TEXT DATA ANALYSIS REPORT"
    echo "========================="
    echo "Input file: $file"
    echo "Generated on: $(date '+%Y-%m-%d %H:%M:%S')"
    echo
    echo "Total words (including stop words): $("$BASE_DIR/cleanup.sh" "$file" | awk '{for(i=1;i<=NF;i++) if($i ~ /[[:alpha:]]/) n++} END {print n+0}')"
    echo "Unique words (including stop words): $("$BASE_DIR/cleanup.sh" "$file" | awk '{for(i=1;i<=NF;i++) if($i ~ /[[:alpha:]]/) a[tolower($i)]=1} END{for(x in a)n++; print n+0}')"
    echo
    sentences
    echo
    echo "Top $n words (excluding stop words):"
    printf 'WORD\tCOUNT\n'
    frequency "$n" false
    ;;
  *) usage ;;
esac
