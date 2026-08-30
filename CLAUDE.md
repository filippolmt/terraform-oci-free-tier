# CLAUDE.md

## Project Overview

OpenTofu/Terraform root module that provisions a self-hosting stack on Oracle
Cloud Infrastructure using only Always Free resources: an ARM64 VM
(`VM.Standard.A1.Flex`) with Docker, optional RunTipi homeserver, optional
WireGuard client. Cloned and applied directly — never consumed as a child
module, which is why the OCI provider is pinned to an exact version.

`CONTEXT.md` is the glossary. It defines the vocabulary this repo uses
everywhere — Always Free, Free Trial, Free Tier account, Pay-As-You-Go account,
Always Free cap, billable resource, home region, idle reclamation — and records
which near-synonyms to avoid. Read it before writing user-facing prose or error
messages. Notably: "Always Free" names the resources, "Free Tier account" names
only the account type.

See [CHANGELOG.md](CHANGELOG.md) for the current version and its breaking
changes, and `docs/adr/` for decisions with their rejected alternatives.

## Commands

`make help` lists every target; `make test` runs the lot (fmt-check → validate →
tofu-test → shellcheck). `CONTRIBUTING.md` covers the local setup — `tofu` and
`shellcheck` on PATH, both from the toolbox.

What those lookups will not tell you:

- **`make init` passes `-upgrade`**, so every `validate`/`test` re-resolves
  `.terraform.lock.hcl`. The exact provider pin in `versions.tf` is what keeps
  plans reproducible; a range constraint would let a provider major land
  silently on whoever runs `init` next. Renovate owns the bump.
- **One test file**: `tofu test -filter=tests/validation_unit_test.tftest.hcl`.
- **terraform-docs and Trivy run only in CI.** There is no local target, so a
  `.tf` change lands with the README tables stale until CI regenerates them.

## Architecture

Requires OpenTofu/Terraform `>= 1.6` — the floor for `check` blocks.

Split by domain, no submodules: `network.tf` (VCN, subnet, internet gateway,
route table, security list), `compute.tf` (instance, reserved public IP, data
sources), `storage.tf` (block volume, attachment, backup policy), `checks.tf`
(Always Free locals, region-subscriptions lookup, advisory `check` block).
State is local by default; `backend.tf.example` has the OCI Object Storage
(S3-compatible) setup.

The instance takes its public IP from a reserved `oci_core_public_ip` attached
via a `data.oci_core_private_ips` lookup, not from `assign_public_ip`. The
Docker volume runs at `vpus_per_gb = 10` (Balanced), the Always Free tier — the
`0` "Lower Cost" value was removed in OCI provider v8.0.0. The backup policy retains
3 days so the tenancy stays under the 5-backup allowance.

## Always Free caps

The caps are **2 OCPUs / 12 GB memory**, **200 GB of block storage** (boot +
Docker volume), and **the tenancy home region** — outside it nothing is Always
Free and the whole deployment is billed, not just the overage. `checks.tf`
holds the shared locals (`within_compute_caps`, `within_storage_cap`,
`region_is_home`, `total_storage_gb`, `home_regions`).

`var.acknowledge_billable_resources` (default `false`) is one flag unlocking all
three. It gates `precondition` blocks that refuse; the `check "always_free_caps"`
block is the advisory half that warns whoever set the flag. Reasoning and
rejected alternatives: `docs/adr/0002-always-free-cap-reduction.md` and
`docs/adr/0003-require-explicit-home-region.md`.

Three things here look like defects and are not:

- **The preconditions live inside the `lifecycle` blocks that already exist** —
  `ignore_changes` on `oci_core_instance.instance`, `prevent_destroy` on
  `oci_core_volume.docker_volume`. A resource takes one `lifecycle` block.
- **`variables.tf` validation ceilings are looser than the caps** (4 OCPUs,
  24 GB — the pre-June-2026 allocation). Blocking at the cap is the
  preconditions' job; validation is the hard ceiling above which the module
  refuses outright.
- **`data.oci_identity_region_subscriptions.tenancy` is `count`-gated** on
  `var.tenancy_ocid != null`, because SecurityToken and principal auth read the
  tenancy from the session profile. With no tenancy the home region is
  unknowable and the check passes rather than blocking. Reading it needs
  `inspect tenancies`; a compartment-scoped user fails on the data source read,
  which `try()` cannot catch.

## Startup script (`scripts/startup.sh`)

**`compute.tf` carries `ignore_changes = [metadata["user_data"]]`, and
cloud-init runs user_data once.** A script change therefore reaches new
instances only. Anything existing users should apply by hand belongs in the
CHANGELOG migration notes.

Rendered through `templatefile()`, so every shell variable needs a matching
Terraform variable in that call — add both together.

Two phases, because Terraform attaches the volume only after the instance
reaches RUNNING and cloud-init would time out waiting:

- **Phase A** (cloud-init): packages, Docker, SSH keys, timezone, OS tuning and
  hardening (journald cap, SSH hardening, nofile and inotify limits, swap,
  auto-reboot, fail2ban). Writes `/opt/mnt-data-setup.sh` and installs the
  `mnt-data-setup.service` oneshot.
- **Phase B** (that service): volume detection with exponential backoff up to
  60 minutes, mount, a Docker systemd override so Docker waits for `/mnt/data`
  on reboot, RunTipi and WireGuard. It re-declares `log()`, `log_error()`,
  `cleanup()` and `retry()` because it runs as its own process.

Phase A must reach the service installation whatever happens, so every optional
step is guarded and logs its failure instead of aborting. The completion marker
`/var/log/.setup_script_completed` is written at the end of Phase B and drives
the unit's `ConditionPathExists=!…` idempotency; Phase B also guards on
`mountpoint -q`.

`DEBIAN_FRONTEND=noninteractive` and `DPkg::Lock::Timeout=60` exist to survive
`unattended-upgrades` races; the volume is mounted by UUID because device names
are not stable; RunTipi installs from a downloaded file rather than a piped
`curl`.

## Network

`network.tf` assembles every security rule in `locals` — read those rather than
the resource. OCI protocol identifiers are strings: `"1"` ICMP, `"6"` TCP,
`"17"` UDP. The always-on ICMP type 3 code 4 rule is Path MTU Discovery, not
ping; ping is `enable_ping`.

## Tests (`tests/*.tftest.hcl`)

Three files on `mock_provider`, so no OCI credentials: `defaults_`
(default values), `validation_` (validation blocks plus the cap, home-region
and auth preconditions), `network_` (rule generation across feature
combinations).

- **A new data source needs a `mock_data` entry in all three files**, and its
  shape must match the provider schema exactly — every attribute of a nested
  object included, or the run fails on `Invalid mock/override field`.
- **`check` blocks are testable.** `tofu test` reports a failed assertion as a
  run failure, so target it with `expect_failures = [check.always_free_caps]`.
  Any run that deliberately exceeds a cap must list the check alongside the
  precondition it expects.
- **`region` has no default**, so every file's `variables` block sets it.

## CI/CD and generated docs

`.github/workflows/terraform.yml` runs `make fmt-check`, `validate`,
`tofu-test`, `shellcheck` — all blocking — uploads a Trivy SARIF scan, and
posts a four-row PR comment. `documentation.yml` runs `terraform-docs` on `.tf`
PRs and pushes the result back to the branch.

**terraform-docs owns everything between the `<!-- BEGIN_TF_DOCS -->` and
`<!-- END_TF_DOCS -->` markers in `README.md`** — Requirements, Providers,
Modules, Resources, Inputs, Outputs. Edit `variables.tf` and let CI regenerate
them; rows are alphabetical, and a new data source gets a Resources row too.
The exception is a fork PR: its `GITHUB_TOKEN` is read-only, the push is
skipped, and the stale table ships until the merge to `main` — so for a change
that alters a default or makes a variable required, update those rows by hand
in the same commit.

Renovate (`renovate.json`) bumps three things: the OCI provider in
`versions.tf`, the GitHub Actions, and the `OPENTOFU_VERSION` pin in
`terraform.yml`. The Ubuntu image OCIDs are **manual** — no manager matches
them — and changing the base image means editing every one of the 35+ entries
in `instance_image_ocids_by_region`.

## Destroying

`oci_core_volume.docker_volume` carries `prevent_destroy = true`. A teardown
means removing that lifecycle rule or `tofu state rm` first — deliberately, since
Always Free A1 capacity is often exhausted and a destroyed instance may not be
recreatable at all.
