# ADR 0005: Server A is standalone — never joins the Proxmox cluster

- Status: Accepted
- Date: 2026-05-10

## Context

Servers B + C + D form a 3-node Proxmox VE cluster on the existing
2.5 GbE Switch Flex fabric (see `dryvist/ansible-proxmox-cluster`).
Server A is the GPU/AI host, with very different lifecycle and resource
characteristics: NixOS instead of Proxmox, GPU-bound workloads,
heavy model storage, no need for VM live-migration or HA.

A previous draft contemplated either:

1. Joining A to the Proxmox cluster as a 4th node (with NixOS replaced
   by Proxmox), or
2. Adding a `mkEnableOption "ten-gig mesh"` flag so A could *optionally*
   participate in a future 4-way mesh fabric.

## Decision

Server A is **standalone**. It runs NixOS, has 1 GbE only, and is
treated as a normal LAN node by the cluster — never a peer.

There is intentionally **no** `mkEnableOption "ten-gig mesh"` flag in
`hosts/ai-server-a/networking.nix`. Adding such a flag would imply the
host could be enrolled into the cluster fabric in the future, which
would mislead readers and tempt drift.

## Consequences

- `hosts/ai-server-a/networking.nix` is 1 GbE only, with no Corosync
  or mesh routing concerns.
- `modules/secrets/openbao-agent.nix` reaches the cluster's OpenBao LXC
  over the regular LAN; it does not assume a private fabric.
- AI workloads on A are pinned to A — there is no live-migration story
  to or from the cluster. Recovery is "reinstall via nixos-anywhere
  and restore models from the HuggingFace cache on `tank`".
- If we ever need GPU workloads on the cluster, that is a *separate*
  host/repo, not a re-architecture of `nix-ai-server`.
