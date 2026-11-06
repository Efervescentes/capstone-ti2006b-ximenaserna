# TI2006B Capstone - Pokémon GO-inspired data analysis

Persistent project home for the TI2006B Capstone (Fall 2026), team **Efervescentes**.
Author: Ximena Serna.

## Project question

Which Pokémon types and species have the highest total base stats, and how do
size (weight) and type relate to those stats?

## Intended audience

Classmates and the instructor of TI2006B who want a small, reproducible example
of a complete beginner data workflow (ingest, join, check, visualize, document).

## Data source

Public, community-maintained Pokémon species, type, and base-stat tables from
the [`veekun/pokedex`](https://github.com/veekun/pokedex) repository. The
notebook downloads them at runtime, so no dataset copy is committed here.
See [`notebooks/README.md`](notebooks/README.md) for provenance and details.

## Expected output

- A data-quality summary (row counts, duplicates, missing values).
- Interactive Plotly charts: distribution of total base stats, top species by
  total stats, count by type, and weight vs. total stats.
- Three written observations and one limitation in the notebook.

## Current limitation

This is a Pokémon GO-inspired teaching context, not Pokémon GO player data. The
tables describe species and base stats only; they do not include accounts,
locations, encounters, captures, or battle results. A high total base stat is
not the same as battle performance in Pokémon GO.

## How to start

1. Clone the repository:
   ```bash
   git clone https://github.com/Efervescentes/capstone-ti2006b-ximenaserna.git
   cd capstone-ti2006b-ximenaserna
   ```
2. Create an environment and install dependencies (pick one):
   ```bash
   # Option A: pip
   python -m venv .venv
   source .venv/bin/activate        # Windows (Git Bash): source .venv/Scripts/activate
   python -m pip install -r requirements.txt

   # Option B: Anaconda
   conda env create -f environment.yml
   conda activate ti2006b-capstone
   ```
3. Open Jupyter and run [`notebooks/01-pokemon-go-analysis.ipynb`](notebooks/01-pokemon-go-analysis.ipynb) from the repository root:
   ```bash
   jupyter lab
   ```

## Repository map

```text
.
├── .github/workflows/   # automated checks (notebook validation, quality)
├── assignments/         # evidence for later activities
├── dashboards/          # BI documentation, exports, screenshots
├── data/
│   ├── raw/             # source snapshots when permitted (not committed by default)
│   └── processed/       # reproducible derived tables
├── docs/                # project charter, architecture, ADRs, governance
├── notebooks/           # exploratory notebooks and data notes
├── reports/             # figures and written findings
├── src/                 # reusable Python code
├── tests/               # unit and data-quality tests
├── environment.yml      # Anaconda environment
├── requirements.txt     # pip dependencies
└── README.md
```

## Rules

- Never commit passwords, API keys, tokens, `.env` files, personal data, or
  confidential company data.
- One focused commit per meaningful change, with a descriptive message.
- Keep notebooks runnable from the repository root.

## Reflection

The hardest part for another student would be not knowing what the project is
about or how to run it, especially because the course has two templates with
different files. When I set up this repository, the Capstone template was
missing the Pokémon notebook and the `requirements.txt` file, so I added them
from the init example to keep everything in one place. I also wrote the
question, data source, and limitation at the top of the README and added a
"How to start" section with the exact commands. The notebook downloads public
data when it runs, so nobody needs to ask me for files to reproduce it.
