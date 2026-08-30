# Follow Oracle's reduced Always Free caps, and gate anything above them

On 15 June 2026 Oracle halved the Always Free allocation for Ampere A1 Compute:
4 OCPUs and 24 GB of memory became 2 OCPUs and 12 GB, and the monthly budget
dropped from 3,000 OCPU hours and 18,000 GB hours to 1,500 and 9,000. There was
no blog post and no changelog entry — the documentation was edited in place.
Emails announcing that non-conforming instances would be terminated from
18 August 2026 reached some tenancies and not others. Block storage was
untouched at 200 GB across boot and block volumes.

We moved the module's defaults to 2 OCPUs and 12 GB, and put anything above the
Always Free caps behind an explicit `acknowledge_billable_resources` opt-in
enforced by `precondition` blocks. The same flag gates the 200 GB storage total,
which the module had never checked at all. This is recorded because the numbers
2 and 12 look arbitrary today and will look inexplicable once Oracle's
documentation shows them as if they had always been the limits.

## On Pay-As-You-Go accounts

Oracle Support told some users that Pay-As-You-Go tenancies keep the old 4/24
allocation at no charge. We do not rely on this and neither should the
documentation: Oracle's own docs apply the new caps to all tenancies, and
Pay-As-You-Go users have reported both the reduction email and billing alerts on
a single 4/24 instance. The opt-in flag exists to avoid breaking users who were
already at 4/24 — not because we believe that configuration is still free for
anyone.

## Considered Options

- **Keep 4/24 and document the change.** Rejected: a default that gets the
  instance terminated is a trap, and the people most likely to hit it are the
  ones who never read the README.
- **Hard-cap validation at 2/12.** Rejected: users who accept a bill are
  entitled to exceed the caps. The module should make overspending deliberate,
  not impossible.
- **Raise the ceiling to the shape maximum (76 OCPUs / 472 GB) once the flag is
  set.** Rejected: the flag exists to avoid breaking users who were already at
  4/24, not to turn a Free Tier module into a general-purpose compute module.
- **Warn instead of block.** Rejected for the opt-in gate — a `check` block
  emits a warning that scrolls past. It is used for the advisory assertions
  only, where not blocking is the point.

## Consequences

- `required_version` moves from `>= 1.3` to `>= 1.6`, the floor for `check`
  blocks. Cross-variable `validation` would have needed `>= 1.9`, which is why
  the gate lives in `precondition` blocks instead.
- Existing users who never pinned the sizing variables get their instance
  resized down to 2/12 on the next apply. `shape_config` changes are an in-place
  resize with a reboot, not a replacement. There is no way to warn about this
  from within the module: a `check` block sees planned values, and reading the
  prior instance state would require a data source keyed on the instance's own
  OCID — a cycle. The major version bump to 5.0.0 and the plan output are the
  only signals available.
- `ignore_changes` on `shape_config` was rejected as a mitigation. It would
  silence the resize but leave the module permanently unable to resize an
  instance.
- Users who did pin 4/24 will have their next apply blocked until they add
  `acknowledge_billable_resources = true`, even for an unrelated change. This is
  deliberate: they are exactly the people who need to learn that their instance
  is now above the caps.
- Destroying an over-cap instance is not reversible in practice. Beyond the caps
  themselves, Always Free A1 capacity is frequently unavailable — "out of
  capacity" on create is the common experience, not the exception. The advisory
  `check` says so explicitly.
- `tofu test` surfaces a failed `check` assertion as a run failure, so the block
  is covered by `expect_failures = [check.always_free_caps]`. The consequence is
  that every test run which deliberately exceeds a cap has to expect the check
  alongside the precondition, even though outside the test harness the check is
  only a warning.
