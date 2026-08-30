# Require an explicit region, and refuse to build outside the home region

Always Free eligibility is scoped to the tenancy's home region. Oracle's
documentation is unambiguous on both halves of what this module builds: "You
must create the Always Free compute instances in your home region", and
"Volumes created outside of the home region incur regular block volume costs."
Deploying to any other region does not cost the excess over the caps — it costs
full price for the instance and for all 200 GB of storage.

The module shipped a `region` default of `eu-milan-1` and never looked at the
tenancy's home region at all. That default is correct for one region's worth of
users and silently expensive for everyone else. We removed the default, making
`region` a required variable, and added a `precondition` that compares it
against `data.oci_identity_region_subscriptions` and refuses to build unless it
matches the home region — overridable with the same
`acknowledge_billable_resources` flag used for the Always Free caps.

This is separate from ADR-0002: the cap reduction is what prompted the audit,
but this trap predates it and would still be worth closing had Oracle changed
nothing.

## Considered Options

- **Derive the region from the tenancy's home region automatically.** Rejected:
  where a user's data physically lives is not a decision a module should make
  on their behalf, however convenient.
- **Keep the default and rely on the precondition alone.** Rejected: a default
  that is wrong for most users is a defect even when something downstream
  catches it. The precondition is the safety net, not the first line.
- **Warn instead of refusing.** Rejected: this is the one failure mode in the
  module where the bill is 100% of the spend rather than the overage.

## Consequences

- Requiring `region` is a breaking change for anyone who relied on the default.
  It ships in 5.0.0 alongside the sizing changes.
- The module now reads `data.oci_identity_region_subscriptions`, so the
  credentials it runs with need permission to list region subscriptions.
- A user who genuinely wants a paid deployment outside their home region can
  still have one by setting `acknowledge_billable_resources = true`. The flag
  now carries two meanings — over the caps, or outside the home region — which
  is acceptable because the question it asks the user is the same one.
