<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Contributing

Short: How to contribute, commit guidelines and tests/validation expectations.

## Commit rules

- We use conventional commit messages. Example: `feat(api): add authentication endpoint`.
- Pre-commit hooks run automatically on commit; run them locally with `pre-commit run --all-files`.

## Code review and PR flow

- Open a PR against `latest` (or the appropriate target branch). The CI will run validation pipelines (see `pipelines/build_validation/`).
- Ensure all checks pass before requesting a review.

## Documentation

- Use `pipelines/src/docs_infra.py` and the docs templates to generate or update docs under `docs/`.

## Licensing

- This repository uses MIT licensing. Add SPDX headers in generated files (the repo's pre-commit hooks validate REUSE headers).
