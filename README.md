# omics-walkthru

A plain-language curriculum on processing sequencing data after library
submission, written for wet-lab scientists with little or no bioinformatics
background. Everything runs on a laptop (macOS, Linux, or Windows with WSL), a
workstation, or a computing cluster, using a small public practice dataset. Built with [Quarto](https://quarto.org) as a book and published to
GitHub Pages: <https://jpflores-13.github.io/omics-walkthru>.

## Modules

| Module | Status | Pipeline it follows |
|---|---|---|
| RNA-seq | written | [bagPipes](https://github.com/PhanstielLab/bagPipes) `RNApipe` |
| ATAC-seq | planned | bagPipes `ATACpipe` |
| ChIP-seq / CUT&Tag / CUT&RUN | planned | bagPipes `ChIPpipe` |

## Layout

```
_quarto.yml          book configuration (chapters, theme)
index.qmd            welcome page
teaching-guide.qmd   session plan for instructors
rna-seq/             RNA-seq module chapters
appendix/            glossary, cheat sheet, troubleshooting, references
envs/                conda environments for the hands-on parts
practice-data/       scripts that download the practice reads and build references
img/                 figures
custom.scss          theme tweaks
```

## Hands-on setup (for learners)

```bash
conda env create -f envs/rnaseq-tools.yml && conda activate rnaseq-tools
bash practice-data/get_practice_data.sh ~/omics-walkthru-practice/practice_data
bash practice-data/get_references.sh ~/omics-walkthru-practice/references chr22   # or: full
```

Full instructions: the *Your practice setup* chapter.

## Build the book locally

```bash
quarto preview      # live preview
quarto render       # writes _book/
```

Pushing to `main` renders the book and deploys it with
`.github/workflows/quarto-publish.yml`. In the repository settings, set
**Pages → Source** to **GitHub Actions** once.

## Adding a module

Make a folder (`atac-seq/`), add its chapters, and add a `part:` for it in
`_quarto.yml`. The Foundations chapters in `rna-seq/` cover the shell and file
formats; ATAC/ChIP-specific formats (narrowPeak, BEDPE, ...) belong in the new module.
