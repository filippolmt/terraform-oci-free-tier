# Drop the CI container image

This repository used to ship a `Dockerfile` that pinned `tofu`, `terraform-docs`, `tflint` and `trivy`, and every `make` target ran through `docker run`. Keeping that image current cost more than it returned: four tool versions to bump, a buildx cache to warm on every CI run, and a Docker daemon required just to format HCL. We removed the image and its `.dockerignore`/`.trivyignore` companions.

Local development now needs only `tofu` and `shellcheck`, both provided by the [toolbox](https://github.com/filippolmt/toolbox), and `make` invokes them directly. In CI, `opentofu/setup-opentofu` installs the pinned OpenTofu version, `terraform-docs/gh-actions` renders the docs, and Trivy runs through `aquasecurity/trivy-action` to publish SARIF to the GitHub Security tab.

## Consequences

- `tflint` is gone entirely. It was `continue-on-error` in CI and its findings overlapped with `tofu validate`; nothing reads its output today.
- Trivy no longer runs locally — `make security` does not exist. Config findings surface only in the Security tab, on push and on PRs from this repository — fork PRs get no `security-events: write`, so the upload is skipped there.
- `terraform-docs` no longer runs locally either. `documentation.yml` auto-commits the rendered README section to the PR branch, so there is no drift check to fail on. It also runs on push to `main`, which is what covers fork PRs.
