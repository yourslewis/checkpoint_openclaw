#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
find_figure_page.sh — locate which PDF page contains a figure caption/number.

Usage:
  find_figure_page.sh [-i] [-a] <paper.pdf> <regex>

Options:
  -i   Case-insensitive match (best-effort; implemented via lowercasing)
  -a   Print ALL matching page numbers (default: first match only)
  -h   Help

Notes:
  - Uses: pdftotext -layout ... and splits pages on formfeed (\f).
  - Provide an awk/ERE regex. Example: 'Figure[[:space:]]*2[[:space:]]*:'

Self-test (replace paper.pdf):
  ./find_figure_page.sh paper.pdf 'Figure[[:space:]]*2[[:space:]]*:'
EOF
}

icase=0
all=0
while getopts ":iah" opt; do
  case "$opt" in
    i) icase=1 ;;
    a) all=1 ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -lt 2 ]]; then
  usage >&2
  exit 2
fi

pdf="$1"
pattern="$2"

if [[ ! -f "$pdf" ]]; then
  echo "ERROR: PDF not found: $pdf" >&2
  exit 2
fi

if ! command -v pdftotext >/dev/null 2>&1; then
  echo "ERROR: pdftotext not found in PATH" >&2
  exit 127
fi

set +e
pages=$(pdftotext -layout "$pdf" - 2>/dev/null | \
  awk -v pat="$pattern" -v icase="$icase" -v all="$all" '
    BEGIN { RS="\f"; found=0 }
    {
      text=$0; p=pat
      if (icase==1) { text=tolower($0); p=tolower(pat) }
      if (text ~ p) {
        found=1
        print NR
        if (all==0) exit 0
      }
    }
    END { if (!found) exit 1 }
  ')
status=$?
set -e

if [[ $status -ne 0 || -z "${pages}" ]]; then
  echo "No match for regex on any page." >&2
  exit 1
fi

printf '%s\n' "$pages"
