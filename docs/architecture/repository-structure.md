# Repository structure

The structure follows learning order while giving reusable artifacts stable homes.

```text
.
├── docs/
│   ├── architecture/       # ownership boundaries and topology decisions
│   ├── concepts/           # primitive and derived-feature catalogs
│   ├── curriculum/         # ordered learning path
│   ├── findings/           # empirical Pi and Qwen observations
│   └── pi-internals/       # targeted source-reading maps and runtime notes
├── labs/                   # guided, runnable learning units
├── extensions/             # reusable Pi extensions promoted from labs
├── harnesses/              # composed Pi configurations (added when exercised)
├── experiments/            # controlled comparisons and raw-analysis code
├── evals/                  # tasks, scorers, and result schemas
├── fixtures/               # small deterministic experiment inputs
├── python/                 # later external orchestration and services
└── scripts/                # repository-wide utilities
```

Empty future directories are not committed. They appear when the first concrete artifact exists. This avoids implying APIs or abstractions before experiments justify them.

A lab may begin with code local to its directory. When an artifact proves reusable, copy or move it into `extensions/`, `harnesses/`, or `python/` and leave the lab pointing to that artifact. Harness directories should contain composition and launch configuration, not forks of Pi.

Generated traces belong in `.lab-output/` and are ignored because they may contain prompts, file contents, or other context sent to the model. Findings committed under `docs/findings/` must be sanitized.

