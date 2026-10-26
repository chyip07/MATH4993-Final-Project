# MATH4993 Final Project

Repository for the MATH4993 final project at HKUST.

## Dataset shortlist

Five downloaded alternatives, selection rationale, suggested models, data dictionaries,
and limitations are in [data/candidates/README.md](data/candidates/README.md).

The five numbered CSVs are ready to read in R or Python. The original source files
and documentation are retained under `data/candidates/raw/`.

Rebuild and validate the CSV exports from the project root:

```sh
Rscript scripts/prepare_candidate_data.R
```
