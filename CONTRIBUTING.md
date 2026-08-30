# Contributing

## Development environment

Local development needs two tools:

- [OpenTofu](https://opentofu.org/docs/intro/install/) — `tofu`
- [ShellCheck](https://www.shellcheck.net/) — `shellcheck`

The recommended way to get both is the [toolbox](https://github.com/filippolmt/toolbox), a container image that ships them already pinned and configured. Install them however you prefer if you would rather not use it; the `Makefile` only assumes the two binaries are on `PATH`.

`tflint`, `Trivy` and `terraform-docs` are **not** part of the local workflow — see [ADR 0001](docs/adr/0001-drop-ci-container-image.md). Trivy runs in CI and reports to the GitHub Security tab; `terraform-docs` runs in CI and commits the rendered README section back to the pull request. Both are skipped on pull requests from forks, whose `GITHUB_TOKEN` is read-only — the docs are rendered on the push to `main` after the merge instead.

## Checks

```bash
make test        # fmt-check + validate + tofu-test + shellcheck — run this before pushing
```

Individual targets:

```bash
make fmt         # auto-format .tf files
make fmt-check   # check formatting without modifying
make validate    # tofu init -backend=false -upgrade + tofu validate
make tofu-test   # OpenTofu native tests (mock provider, no OCI credentials needed)
make shellcheck  # lint scripts/*.sh
make clean       # remove .terraform/
make help        # list all targets
```

To run a single test file:

```bash
tofu test -filter=tests/validation_unit_test.tftest.hcl
```

## Pull requests

- `make test` must pass. The same checks run in CI (`.github/workflows/terraform.yml`) and post a results table on the pull request.
- Let `.github/workflows/documentation.yml` regenerate the terraform-docs tables in `README.md`; it commits them back whenever a `.tf` file changes. The exception is a pull request from a fork: its `GITHUB_TOKEN` cannot push, so the stale table ships until the merge to `main`. When a change alters a default or makes a variable required, update those rows by hand in the same commit.
- Note user-facing changes in `CHANGELOG.md` under `## [Unreleased]`, creating that section if the last release closed it.
- `CONTEXT.md` is the project glossary. Follow it for user-facing prose and error messages — it fixes which term to use for the Always Free resources, the account types, the caps and the home region, and lists the near-synonyms to avoid.
