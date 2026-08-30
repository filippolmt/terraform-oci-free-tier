# Terraform OCI Free Tier

Terraform/OpenTofu module that provisions a self-hosting stack on Oracle Cloud
Infrastructure using only perpetually free resources. This document is the
project glossary — it defines the domain vocabulary and nothing else.

## Language

### Oracle account and entitlements

**Always Free**:
The set of OCI resources Oracle grants perpetually at no cost, with fixed
per-tenancy caps. This is what the module targets.
_Avoid_: Free Tier (as a name for the resources), free resources

**Free Trial**:
The time-limited grant of promotional credits Oracle gives a new tenancy. Not
what the module targets, and unrelated to the Always Free caps.
_Avoid_: Free Tier (as a name for the trial), trial credits

**Free Tier account**:
A tenancy that has never been upgraded to paid billing. It can consume Always
Free resources only; anything beyond the caps is refused or shut down rather
than billed.
_Avoid_: free account, non-paying account

**Pay-As-You-Go account**:
An upgraded tenancy with a payment method attached. It still receives the
Always Free allocation, but resources beyond the caps are billed instead of
refused.
_Avoid_: PAYG account (in prose), paid account, billable account

**Always Free cap**:
A per-tenancy ceiling on an Always Free resource — for example 2 OCPUs and
12 GB of memory for Ampere A1 Compute, or 200 GB of total block storage.
Exceeding a cap has different consequences depending on the account type.
_Avoid_: Free Tier limit, quota

**Billable resource**:
A resource the module would provision above an Always Free cap. On a
Pay-As-You-Go account it incurs charges; on a Free Tier account it is refused.
_Avoid_: paid resource, over-limit resource

**Home region**:
The single region a tenancy is anchored to at sign-up. Always Free eligibility
is scoped to it: compute instances and block volumes created anywhere else are
billed at full price rather than counted against the caps.
_Avoid_: primary region, default region

**Idle reclamation**:
Oracle's reclaiming of an Always Free compute instance that stayed below 20%
CPU, network, and memory utilisation over a seven-day window. Independent of
the caps — a perfectly compliant instance can still be reclaimed.
_Avoid_: idle shutdown, instance cleanup

### Provisioned infrastructure

**Instance**:
The single ARM64 compute VM the module creates, running the container
workloads.
_Avoid_: server, machine, node, VM

**Docker volume**:
The separate block volume mounted at `/mnt/data` that holds all container
data, kept distinct from the instance's boot volume so it survives instance
replacement.
_Avoid_: data volume, secondary volume, disk

**Boot volume**:
The block volume the instance boots from, created as part of the instance and
destroyed with it.
_Avoid_: root volume, system disk

**Startup script**:
The shell script rendered into the instance's `user_data` that brings the
instance from a bare image to a running stack.
_Avoid_: cloud-init script, bootstrap script, provisioning script
