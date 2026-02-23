#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
extract_figure_by_caption.sh — find the page containing a figure caption, then render that page to a standardized filename.

Usage:
  extract_figure_by_caption.sh [-i] [-r dpi] [-d outdir] <paper.pdf> <figure_number> <slug> [regex]

Arguments:
  paper.pdf        Input PDF
  figure_number    Figure number (integer, e.g., 2)
  slug             Short human label used in the output filename (e.g., "system architecture")
  regex            Optional override (awk/ERE). If omitted, defaults to matching:
                   (Figure|Fig\.?)[[:space:]]*<N>[[:space:]]*[:.]

Options:
  -i        Case-insensitive match (best-effort)
  -r dpi    Render DPI (default: 150)
  -d outdir Output directory (default: current directory)
  -h        Help

Output:
  Prints the final PNG path, e.g.: fig2_system_architecture.png

Self-test (replace paper.pdf):
  ./extract_figure_by_caption.sh -i -r 150 -d . paper.pdf 2 "system architecture"
EOF
}

icase=0
dpi=150
outdir="."
while getopts ":ir:d:h" opt; do
  case "$opt" in
    i) icase=1 ;;
    r) dpi="$OPTARG" ;;
    d) outdir="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -lt 3 ]]; then
  usage >&2
  exit 2
fi

pdf="$1"
fig="$2"
slug="$3"
regex="${4:-}"

if [[ ! "$fig" =~ ^[0-9]+$ ]] || [[ "$fig" -le 0 ]]; then
  echo "ERROR: figure_number must be a positive integer. Got: $fig" >&2
  exit 2
fi

if [[ ! -f "$pdf" ]]; then
  echo "ERROR: PDF not found: $pdf" >&2
  exit 2
fi

slugified=$(printf '%s' "$slug" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/_/g; s/^_+|_+$//g; s/__+/_/g')

if [[ -z "$slugified" ]]; then
  echo "ERROR: slug became empty after sanitization; provide a more descriptive slug" >&2
  exit 2
fi

mkdir -p "$outdir"
final_png="$outdir/fig${fig}_${slugified}.png"

if [[ -z "$regex" ]]; then
  # Default tries to catch: "Figure 2:" and "Fig. 2." variants.
  regex="(Figure|Fig\\.?)[[:space:]]*${fig}[[:space:]]*[:.]"
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

page=$(
  "$script_dir/find_figure_page.sh" $( [[ $icase -eq 1 ]] && printf -- '-i' ) "$pdf" "$regex" \
    | head -n1
)

# Render the page to a temp file then copy to standardized name.
# (Rendering directly to final name is fine too, but the temp makes failures safer.)
tmp_png=$(mktemp --suffix=.png)
trap 'rm -f "$tmp_png"' EXIT

"$script_dir/extract_pdf_page_png.sh" -r "$dpi" -o "$tmp_png" "$pdf" "$page" >/dev/null

cp -f "$tmp_png" "$final_png"

printf '%s\n' "$final_png"
