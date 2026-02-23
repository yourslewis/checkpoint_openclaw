---
name: paper-review
description: End-to-end academic/industry paper review workflow. Use when asked to search/download a paper, create a structured paper folder, extract text, summarize challenges/initiatives/methodology/experiments/references in LaTeX, and push results to GitHub via PR.
---

# Paper Review Workflow

Follow this flow to complete a paper review end-to-end and deliver a PR.

## 1) Locate and download the paper
- Prefer official sources (arXiv, publisher site, Google Research).
- Save into workspace under: `papers/<affiliation>_<papername>/`.
- Use a stable filename: `<SHORTNAME>_<YEAR>.pdf`.

## 2) Prepare the paper folder
- Create folder `papers/<affiliation>_<papername>/`.
- Copy the PDF there.
- Extract text with `pdftotext -layout` to `<SHORTNAME>_<YEAR>.txt`.
- Keep any extraction helpers (e.g., `refs_tail.txt`).

## 3) Summarize in LaTeX
- Use `references/template_summary.tex` as the structure.
- Write detailed sections:
  - Challenges
  - Key Initiatives
  - Methodology
  - Experiments
  - References (selected)
- Include short, verbatim quotes from the paper where helpful (with quotation marks) to ground key claims.
- Keep claims grounded in the paper’s text.

### Quoting (to enrich the summary)
- Use **short, verbatim** phrases (1–2 lines) to anchor key claims (e.g., a stated metric, a design rationale).
- Always wrap quotes in quotation marks and place them near the claim they support.
- Prefer quotes that define a term, state an objective, or give a numeric result.

### Selecting references (curation rules)
- Include works **explicitly cited** by the paper as baselines or directly compared methods.
- If the user asks for themed subsets (e.g., “big-company references”), only include **companies actually cited**; list non‑cited companies as “not cited in this paper.”
- Keep the list short and directly tied to the paper’s experiments or positioning.

### Selecting the figure (avoid mistakes)
- Prefer the **model architecture/design overview** figure when present.
- Verify the figure **by caption** before embedding:
  1) Locate the figure number and title in the extracted text.
  2) Open the corresponding page image to confirm the caption matches.
  3) Rename the image to a figure‑named file (e.g., `fig2_model_design.png`) and embed that in LaTeX.
- Do not embed by “page number” alone; captions are the source of truth.

#### Helpers (scripts/)
These scripts automate the “find caption → confirm page → render only that page → standardized filename” loop:

- Find the PDF page containing a caption/figure number:
  - `skills/paper-review/scripts/find_figure_page.sh paper.pdf 'Figure[[:space:]]*2[[:space:]]*:'`

- Render **one page only** (avoids accidentally rendering the whole PDF):
  - `skills/paper-review/scripts/extract_pdf_page_png.sh -r 150 -o page7.png paper.pdf 7`

- One-shot wrapper (find + render + standardized naming):
  - `skills/paper-review/scripts/extract_figure_by_caption.sh -i paper.pdf 2 "system architecture"`
  - → outputs: `./fig2_system_architecture.png`

## 4) Compile & render PDF
- Compile the LaTeX summary:
  - `pdflatex -interaction=nonstopmode -halt-on-error summary.tex`
- Render pages to images (preferred):
  - All pages: `mutool draw -r 150 -o summary_page_%d.png summary.pdf`
  - Single page: `mutool draw -r 150 -o page7.png summary.pdf 7` (page selection is a trailing arg)
- Share rendered images with the user when asked.

## 5) GitHub logging via PR
- Clone the target repo if needed.
- Copy the `papers/` folder into the repo.
- Create a branch: `paper/<shortname>-<year>`.
- Commit with message: `Add <Paper> <Year> paper + LaTeX summary`.
- Push and provide the PR link to the user.

## 6) Completion criteria
A task is complete when:
- The paper folder exists with PDF, text, and `summary.tex`.
- `summary.pdf` and rendered images are generated (or a clear reason is provided if not).
- A PR is open with those files.
- The PR link is sent to the user.

## Reference
- LaTeX template: `references/template_summary.tex`.
