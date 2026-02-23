#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
extract_pdf_page_png.sh — render a SINGLE PDF page to a PNG.

Usage:
  extract_pdf_page_png.sh [-r dpi] [-o out.png] <paper.pdf> <page>

Options:
  -r dpi     Resolution in DPI (default: 150)
  -o out.png Output PNG path (default: <pdfbase>_page<N>.png)
  -h         Help

Why this exists:
  - MuPDF's `mutool draw` takes page numbers as a TRAILING argument list.
    `-p` is for password, not page selection (common mistake).

Self-test (replace paper.pdf):
  ./extract_pdf_page_png.sh -r 150 -o page7.png paper.pdf 7
EOF
}

dpi=150
out=""
while getopts ":r:o:h" opt; do
  case "$opt" in
    r) dpi="$OPTARG" ;;
    o) out="$OPTARG" ;;
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
page="$2"

if [[ ! -f "$pdf" ]]; then
  echo "ERROR: PDF not found: $pdf" >&2
  exit 2
fi

if [[ ! "$page" =~ ^[0-9]+$ ]] || [[ "$page" -le 0 ]]; then
  echo "ERROR: page must be a positive integer (1-indexed). Got: $page" >&2
  exit 2
fi

if [[ -z "$out" ]]; then
  base="$(basename "$pdf")"
  base="${base%.pdf}"
  out="${base}_page${page}.png"
fi

mkdir -p "$(dirname "$out")" 2>/dev/null || true

# Prefer MuPDF.
if command -v mutool >/dev/null 2>&1; then
  # Correct syntax: page selection is a trailing argument (NOT -p).
  mutool draw -F png -r "$dpi" -o "$out" "$pdf" "$page"
  if [[ ! -s "$out" ]]; then
    echo "ERROR: mutool did not produce output: $out" >&2
    exit 1
  fi
  printf '%s\n' "$out"
  exit 0
fi

# Fallback: poppler utils.
if command -v pdftoppm >/dev/null 2>&1; then
  outbase="${out%.png}"
  pdftoppm -f "$page" -l "$page" -png -singlefile "$pdf" "$outbase" >/dev/null
  if [[ ! -s "$out" ]]; then
    # pdftoppm writes <outbase>.png
    if [[ -s "${outbase}.png" ]]; then
      mv -f "${outbase}.png" "$out"
    fi
  fi
  if [[ ! -s "$out" ]]; then
    echo "ERROR: pdftoppm did not produce output: $out" >&2
    exit 1
  fi
  printf '%s\n' "$out"
  exit 0
fi

echo "ERROR: need either 'mutool' (MuPDF) or 'pdftoppm' (poppler) in PATH" >&2
exit 127
