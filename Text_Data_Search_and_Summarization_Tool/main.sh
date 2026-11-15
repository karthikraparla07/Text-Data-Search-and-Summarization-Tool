#!/usr/bin/env bash
# Interactive interface and command-line entry point.
set -euo pipefail
BASE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
usage() {
  cat <<'HELP'
Usage:
  ./main.sh                           Interactive menu
  ./main.sh search <file> <regex>     grep -E regex search
  ./main.sh clean <file>              Print cleaned text
  ./main.sh frequency <file> [N] [--keep-stopwords]
  ./main.sh sentences <file>
  ./main.sh report <file> [N]         Save a report in output/
HELP
}
run_report() {
  local file=$1 n=${2:-10} basename stamp dest
  [[ -f "$file" ]] || { echo "File not found: $file" >&2; return 2; }
  basename=$(basename -- "$file"); basename=${basename%.*}
  basename=${basename//[^a-zA-Z0-9_-]/_}
  stamp=$(date '+%Y%m%d_%H%M%S')
  mkdir -p "$BASE_DIR/output"
  dest="$BASE_DIR/output/${basename}_report_${stamp}.txt"
  "$BASE_DIR/summarize.sh" report "$file" "$n" | tee "$dest"
  echo
  echo "Report saved to: $dest"
}
run_command() {
  local cmd=${1:-}; shift || true
  case "$cmd" in
    search) "$BASE_DIR/search.sh" "$@" ;;
    clean) "$BASE_DIR/cleanup.sh" "$@" ;;
    frequency|sentences) "$BASE_DIR/summarize.sh" "$cmd" "$@" ;;
    report) [[ $# -ge 1 && $# -le 2 ]] || { usage; return 2; }; run_report "$@" ;;
    help|-h|--help) usage ;;
    *) usage; return 2 ;;
  esac
}
if [[ $# -gt 0 ]]; then run_command "$@"; exit; fi
while true; do
  cat <<'MENU'

========== TEXT DATA SEARCH & SUMMARIZATION ==========
1. Search for a word / regex (grep)
2. Clean text (sed)
3. Show top N frequent words (awk)
4. Analyze sentence lengths (awk)
5. Generate a full report
6. Exit
======================================================
MENU
  read -r -p 'Enter choice [1-6]: ' choice || break
  case "$choice" in
    6) echo 'Goodbye!'; break ;;
    1|2|3|4|5)
      read -r -p 'Enter input file path [data/sample.txt]: ' file || break
      file=${file:-$BASE_DIR/data/sample.txt}
      [[ -f "$file" ]] || { echo "File not found: $file"; continue; }
      case "$choice" in
        1) read -r -p 'Enter word or extended regex: ' pattern || break
           run_command search "$file" "$pattern" || echo 'Search failed.' ;;
        2) run_command clean "$file" || echo 'Cleaning failed.' ;;
        3) read -r -p 'How many top words? [10]: ' n || break; n=${n:-10}
           read -r -p 'Remove stop words? [Y/n]: ' remove || break
           if [[ "$remove" == n || "$remove" == N ]]; then
             run_command frequency "$file" "$n" --keep-stopwords || echo 'Frequency failed.'
           else run_command frequency "$file" "$n" || echo 'Frequency failed.'; fi ;;
        4) run_command sentences "$file" || echo 'Analysis failed.' ;;
        5) read -r -p 'How many top words? [10]: ' n || break
           run_command report "$file" "${n:-10}" || echo 'Report failed.' ;;
      esac ;;
    *) echo 'Invalid choice. Choose 1 to 6.' ;;
  esac
done
