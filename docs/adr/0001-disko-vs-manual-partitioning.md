# ADR 0001: disko for partitioning, not manual ad-hoc layouts

- Status: Accepted
- Date: 2026-05-10

## Context

Server A's storage layout is non-trivial — NVMe root with btrfs subvols
(`@`, `@home`, `@nix`, `@var`), an SSD acting as an L2ARC cache device,
and four 4 TB HDDs in a `tank` ZFS RAIDZ2 pool. Doing this manually
(parted/mkfs/zpool create) before the first NixOS install is brittle,
unrepeatable, and divorces the partition layout from the flake that
later mounts everything.

## Decision

Use **disko** (`github:nix-community/disko`) for the entire layout.
The same `hosts/ai-server-a/disko.nix` module is consumed both at
install time (via `nixos-anywhere`) and at evaluation time (via
`config.fileSystems` generation), so the shape of the disks lives in
git alongside the rest of the host configuration.

## Consequences

- The disk layout is reviewable in PRs, just like any other Nix module.
- `nixos-anywhere --flake .#ai-server-a` does the right thing on a
  fresh box without manual prep.
- Re-installs are reproducible — bit-for-bit identical layouts.
- Real `by-id` paths for the four HDDs and the L2ARC SSD do NOT land
  until PR #2; today's `disko.nix` uses placeholder paths so an
  accidental run cannot wipe a real device.
